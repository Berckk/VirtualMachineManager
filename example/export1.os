#Использовать VirtualMachineManager
#Использовать logos


Лог = Логирование.ПолучитьЛог("oscript.lib.vm");
Лог.УстановитьУровень(УровниЛога.Отладка);

БезОшибок = Истина;
МВМ = Новый МенеджерВиртуальныхМашин;
МВМ.ПолучитьСтатусы();

