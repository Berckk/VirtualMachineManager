# VirtualMachineManager

```
#Использовать VirtualMachineManager
#Использовать logos

Лог = Логирование.ПолучитьЛог("oscript.lib.vm");
Лог.УстановитьУровень(УровниЛога.Информация);

БезОшибок = Истина;
МВМ = Новый МенеджерВиртуальныхМашин;
Путь = "E:\vms_export_" + Формат(ТекущаяДата(), "ДФ=""гггг-ММ-дд-ЧЧ-мм""");
БезОшибок = МВМ.Выгрузить(Истина, Путь);
Если НЕ БезОшибок Тогда
	ВызватьИсключение "Ошибка";
конецЕсли;
```



[Powershell команды](http://kagarlickij.com/hyper-v-backups-with-powershell/ )