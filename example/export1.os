#Использовать VirtualMachineManager
#Использовать logos


Лог = Логирование.ПолучитьЛог("oscript.lib.vm");
Лог.УстановитьУровень(УровниЛога.Отладка);

БезОшибок = Истина;
МВМ = Новый МенеджерВиртуальныхМашин;
ВсеСтатусы = МВМ.ПолучитьСтатусы();
ВсеСостояния = МВМ.ПолучитьСостояния();

Для Каждого Статус ИЗ ВсеСтатусы Цикл
	Сообщить(Статус);
КонецЦикла;

Для Каждого Состояние ИЗ ВсеСостояния Цикл
	Сообщить(Состояние);
КонецЦикла;


