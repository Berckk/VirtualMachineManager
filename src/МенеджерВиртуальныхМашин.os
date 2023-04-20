#Использовать 1commands
#Использовать logos

Перем Приложение; // Путь к исполняемому файлу powershell
Перем Лог; // Лог
Перем ВиртуальныеМашины; // Массив виртуальных машин.

// Создает новый каталог для последующих бэкапов.
//
// Параметры:
//  Путь  - Строка - Расположение каталога бэкапа.
//
//
Функция УстановитьПутьБэкапа(Знач ПутьБэкапа)
	СоздатьКаталог(ПутьБэкапа);
	Лог.Информация("Путь выгрузки = %1", ПутьБэкапа);
	Возврат ПутьБэкапа;
КонецФункции

// Выгрузка виртуальной машины в бэкап.
//
// Параметры:
//  Работающие  - Истина - Ложь - Обязательный
//  Путь   - Строка - Обязательный - Каталог куда будет выгружаться виртуальные машины. Должен быть пустым.
//
// Возвращаемое значение:
//   Истина - успех, описание ошибки в случае неудачи.
//
Функция Выгрузить(Знач Работающие, Знач Путь) Экспорт
	Ожидаем.Что(Работающие, "Передан аргумент неверного типа").ИмеетТип("Булево");
	Ожидаем.Что(Путь, "Передан аргумент неверного типа").ИмеетТип("Строка");
	ПутьБэкапа = УстановитьПутьБэкапа(Путь);

	ЕстьОшибка = Ложь;
	Для Каждого ВМ ИЗ ВиртуальныеМашины Цикл
		Если (Работающие И Вм.Работает) ИЛИ Не Работающие Тогда
			Если НЕ ВМ.Выгрузить(Путь) Тогда
				Лог.Ошибка("Не удалось выгрузить %1", Вм.Имя);
				ЕстьОшибка = Истина;
			ИначеЕсли Работающие и НЕ ВМ.ПолучитьСостояние() = "Running" Тогда
				ВМ.Запустить();
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Лог.Информация("Выгрузка завершена.");
	Возврат Не ЕстьОшибка;
КонецФункции // Выгрузить(Знач ИмяВМ)

Процедура ЗагрузитьИнформациюВМ()
	
	ТекстКоманды = " Get-VM | Select-Object Name";
	СтрСписокВМ = ВыполнитьКоманду(ТекстКоманды, Истина);
	МассивВМ    = ПреобразоватьВыводВМассив(СтрСписокВМ);

	ВиртуальныеМашины = Новый Массив();
	Для каждого ИмяВМ Из МассивВМ Цикл
		ВМ = Новый ВиртуальнаяМашина(ИмяВМ); 
		ВиртуальныеМашины.Добавить(ВМ);
	КонецЦикла;

КонецПроцедуры // ВиртуальныеМашины()

Функция  ПолучитьСтатусы() Экспорт
	Статусы = Новый Массив();	
	Для каждого ВМ Из ВиртуальныеМашины Цикл
		ТекСтатус = ВМ.Имя + "-" + ВМ.ПолучитьСтатус();
		Лог.Отладка(ТекСтатус);
		Статусы.Добавить(ТекСтатус);
	КонецЦикла;
	Возврат Статусы;
КонецФункции // ПолучитьСтатусы()

Функция  ПолучитьСостояния() Экспорт
	Состояния = Новый Массив();	
	Для каждого ВМ Из ВиртуальныеМашины Цикл
		ТекСостояние = ВМ.Имя + "-" + ВМ.ПолучитьСостояние();
		Лог.Отладка(ТекСостояние);
		Состояния.Добавить(ТекСостояние);
	КонецЦикла;
	Возврат Состояния;
КонецФункции // ПолучитьСостояния()


Функция ПолучитьВиртуальныеМашины(Знач Все = Истина) Экспорт
	МассивВМ = Новый Массив();
	Для Каждого ВМ ИЗ ВиртуальныеМашины Цикл
		Если (Не Все И Вм.Работает) ИЛИ Все Тогда
			МассивВМ.Добавить(ВМ);
		КонецЕсли;
	КонецЦикла;
	Возврат МассивВМ;
КонецФункции


Функция ПреобразоватьВыводВМассив(Знач ТекстВывода)

	МассивВывода = СтрРазделить(ТекстВывода,Символы.ВК+Символы.ПС,Ложь);
	Если Лев(СокрЛП(МассивВывода.Получить(1)),3) = "---" Тогда
		МассивВывода.Удалить(1);
		МассивВывода.Удалить(0);	
	КонецЕсли;
	Если ПустаяСтрока(МассивВывода.Получить(МассивВывода.Количество()-1)) Тогда
		МассивВывода.Удалить(МассивВывода.Количество()-1);
	КонецЕсли;

	Возврат МассивВывода;

КонецФункции


// Создает новую виртуальную машину
//
// Параметры:
//  ИмяВМ - Строка - Обязательный - Наименование виртуальной машины
//
// Возвращаемое значение:
//   Истина - Успех или исключение в случае неудачи.
//
Функция Создать(Знач ИмяВМ) Экспорт

	ТекстКоманды = "New-VM -Name " + ИмяВМ + "";
	Результат = ВыполнитьКоманду(ТекстКоманды);
	Если НЕ ПустаяСтрока(Результат) Тогда
		Лог.Ошибка(Результат);
		ВызватьИсключение Результат;
	КонецЕсли; 
	ВМ = Новый ВиртуальнаяМашина(ИмяВМ); 
	ВиртуальныеМашины.Добавить(ВМ);
	Возврат ВМ;
КонецФункции // Создать()

// Удаляет виртуальную машину
//
// Параметры:
//  ИмяВМ - Строка - Обязательный - Наименование виртуальной машины
//
// Возвращаемое значение:
//   Истина - Успех или исключение в случае неудачи.
//
Функция Удалить(Знач ИмяВМ) Экспорт

	ТекстКоманды = "Remove-VM -Name '" + ИмяВМ + "' -Force";
	Результат = ВыполнитьКоманду(ТекстКоманды);
	Если НЕ ПустаяСтрока(Результат) Тогда
		Лог.Ошибка(Результат);
		ВызватьИсключение Результат;
	КонецЕсли; 
	Для ИИ = 0 По ВиртуальныеМашины.Количество() - 1 Цикл
		Если ВиртуальныеМашины[ИИ].Имя = ИмяВМ  Тогда
			ВиртуальныеМашины.Удалить(ИИ);
		КонецЕсли;
	КонецЦикла;

	Возврат Истина;
КонецФункции // Создать()

// Загрузка виртуальной машины из бэкапа.
//
// Параметры:
//  ПутьXML  - Строка - C:\VM\Virtual Machines\4596AEB4-AB71-43E2-9B1D-4579B7CFC4D1.xmll
//
// Возвращаемое значение:
//   Истина - успех, описание ошибки в случае неудачи.
//
Функция Загрузить(Знач ПутьXML) Экспорт

	ТекстКоманды = "Import-VM -Path '" + ПутьXML + "' -Copy -GenerateNewID";
    Возврат ВыполнитьКоманду(ТекстКоманды);

КонецФункции // Загрузит/(Знач ИмяВМ)

Функция ПолучитьКомандныйФайл()
	КомандныйФайл = Новый КомандныйФайл;
	КомандныйФайл.УстановитьПриложение(Приложение);
	КомандныйФайл.Создать(, ".ps1");
	Возврат КомандныйФайл;
КонецФункции

Функция ВыполнитьКоманду(ТекстКоманды, ОжидатьВывод = Ложь)

	КомандныйФайл = ПолучитьКомандныйФайл();
	КомандныйФайл.УстановитьКодировкуВывода("utf-8");
	КомандныйФайл.ДобавитьКоманду(ТекстКоманды);
	Лог.Отладка(ТекстКоманды);
	ПутьКМ = КомандныйФайл.ПолучитьПуть();
	Лог.Отладка(ПутьКМ);
	КодВозврата = КомандныйФайл.Исполнить();

	Вывод = КомандныйФайл.ПолучитьВывод();

	УдалитьКомандныйФайл(ПутьКМ);

	Если Не ОжидатьВывод и НЕ ПустаяСтрока(Вывод) Тогда
		Лог.Ошибка(Вывод);
		Возврат Ложь;
	ИначеЕсли ОжидатьВывод Тогда
		Возврат Вывод;
	КонецЕсли;

	Возврат Истина;
	
КонецФункции

Процедура УдалитьКомандныйФайл(ПутьКМ)
	Файл = Новый Файл(ПутьКМ);
	Если Файл.Существует() Тогда
		Попытка
			УдалитьФайлы(ПутьКМ);
			Лог.Отладка("Удалили командный файл");
		Исключение
			Лог.Отладка("Не удалось удалить командный файл
			|"+ОписаниеОшибки());
		КонецПопытки
	КонецЕсли;	
КонецПроцедуры


// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.vm";
КонецФункции

//Устанавливает контекст окружения
Процедура УстановитьГипервизор()

	Приложение = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe";

	Файл = Новый Файл (Приложение);
	Если НЕ Файл.Существует() Тогда
		Приложение = "C:\Windows\syswow64\Windowspowershell\v1.0\powershell.exe";
	КонецЕсли;

	Файл = Новый Файл (Приложение);
	Если НЕ Файл.Существует() Тогда
		ТекстИсключения = "Не удалось найти оболочку командной строки powershell.";
		Лог.Ошибка(ТекстИсключения);
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;

	Лог.Отладка("Приложение = %1", Приложение);

//      Для 64bit PowerShell если стоит 64 битная система или 32bit PowerShell, если стоит 32 битная система
//      "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
//      Для 32bit PowerShell на 64 битных системах находится в папке:
//      "C:\Windows\syswow64\Windowspowershell\v1.0\powershell.exe"
	
КонецПроцедуры

// Инициализация работы библиотеки.
// Задает минимальные настройки.
//
Процедура ПриСозданииОбъекта()
	
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

	Лог.Отладка(СистемнаяИнформация.ВерсияОС);
	
	Если не ЭтоWindows Тогда
		ТекстИсключения = "Работа предусмотрена только в ОС Windows!";
		Лог.Ошибка(ТекстИсключения);
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;
	
	УстановитьГипервизор();
	ЗагрузитьИнформациюВМ();
КонецПроцедуры
