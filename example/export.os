#Использовать 1commands


Перем вм;
Перем ПутьБэкапаНовый;
Перем ПутьБэкапа;
Перем Команда;





Процедура ЗапускВыгрузок()
	
	
	
	вм = Новый вм;
	Команда = новый команда;
	
	ПутьБэкапа = "E:\vms_export";
	ПутьБэкапаНовый = ПутьБэкапа+"_new";
	СоздатьКаталог(ПутьБэкапа);
	СоздатьКаталог(ПутьБэкапаНовый);
	
	
	
	
	ВыгрузитьВМ("_DC1");
	ВыгрузитьВМ("_MAIL");
	ВыгрузитьВМ("_NAT");
	ВыгрузитьВМ("_OpenVPN");
	ВыгрузитьВМ("_TRM1");
	ВыгрузитьВМ("_US1");
	//ВыгрузитьВМ("TEST");
	
	
КонецПроцедуры



Процедура ВыгрузитьВМ(ИмяВМ)
	Результат = вм.Выгрузить(ИмяВМ,ПутьБэкапаНовый);
	
	Если не Результат Тогда
		Сообщить(Результат);
	Иначе
		сообщить("Выгрузили "+ИмяВМ+".");
	КонецЕсли;
	
	ПутьДисков = ПутьБэкапаНовый+"\"+ИмяВМ+"\Virtual Hard Disks\";
	Сообщить(ПутьДисков);
	НайденныеФайлы = НайтиФайлы(ПутьДисков, "*.vhdx");
	Если НайденныеФайлы.Количество()=0 Тогда
		Сообщить("Не удалось выгрузить "+ИмяВМ);
	Иначе
		Команда. УстановитьКоманду("c:\Program Files\7-Zip\7z.exe");
		Команда.ДобавитьПараметр(" a -t7z -ssw -slp -mx4 -mmt=4 -scsWIN -stl -m0=lzma2 "+ПутьБэкапа+"\"+ИмяВМ+"  "+ПутьБэкапаНовый+"\"+ИмяВМ +"");
		Команда.Исполнить();
		Сообщить(Команда.ПолучитьВывод());
		
	КонецЕсли;
КонецПроцедуры




Процедура Выгрузить()
	ВМ = Новый МенеджерВиртуальныхМашин;
	ВМ.УстановитьГиперВизор("hyper-v");
	Путь = "e:\vms_export_"+Формат(ТекущаяДата(),"ДФ=""гггг-ММ-дд-ЧЧ-мм""");
	вм.УстановитьПутьБэкапа(Путь);
	МассивВМ = ВМ.ПолучитьВиртуальныеМашины(Ложь);
	ВМ.Выгрузить(МассивВМ);
	
	МассивНеВыгруженныхВМ = новый Массив;
	
	Для каждого ИмяВМ Из МассивВМ Цикл
		ПутьДисков = Путь+"\"+ИмяВМ+"\Virtual Hard Disks\";	
		НайденныеФайлы = НайтиФайлы(ПутьДисков, "*.vhdx");
		Если НайденныеФайлы.Количество()=0 Тогда
			МассивНеВыгруженныхВМ.Добавить(ИмяВМ);
			Сообщить("Не удалось выгрузить "+ИмяВМ);
		Иначе
			// TODO: Архивирование.
		КонецЕсли;
	КонецЦикла;
	
	КомандныйФайл = Новый КомандныйФайл;
	КомандныйФайл.УстановитьПриложение("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe");
	КомандныйФайл.ПоказыватьВыводНемедленно(Ложь);
	КомандныйФайл.Создать(,".ps1");
	
	
	Если МассивНеВыгруженныхВМ.Количество()>0  Тогда
		КомандныйФайл.ДобавитьКоманду("$Result = ""Failure""");
		ТекстКоманды = "Write-EventLog -LogName Application -Source ""Backup scripts"" -EntryType Warning -EventId 2 -Message ""Hyper-V VMs NO Export $Result. Exported VMs: "
		+СтрСоединить(МассивНеВыгруженныхВМ,",");
	Иначе
		КомандныйФайл.ДобавитьКоманду("$Result = ""Success""");
		ТекстКоманды = "Write-EventLog -LogName Application -Source ""Backup scripts"" -EntryType Information -EventId 1 -Message ""Hyper-V VMs Export $Result. Exported VMs: "
		+СтрСоединить(МассивВМ,",");
		КомандныйФайл.ДобавитьКоманду(ТекстКоманды);
	КонецЕсли;	
	
	
	
	# Send result to email
	$From = "gitlab@ts.ru"
	$To = "hpa@ts.ru"
	$Subject = "Hyper-V VMs Export on $Hostname $Date $Result"
	
	$Body = "Hyper-V VMs Export on $Hostname $Date <br>"
	$Body += "Result: <b>$Result</b> <br>"
	$Body += "<br>"
	$Body += "Exported VMs: $ExportedVMs <br>"
	
	$SMTPServer = "mail.ts.ru"
	$SMTPPort = "587"
	
	$MailPass = Get-Content C:\Admin-script\MailboxSecurePass.txt | ConvertTo-SecureString
	$MailCred = New-Object -TypeName System.Management.Automation.PSCredential  `
	-argumentlist "gitlab@ts.ru", $MailPass
	
	Send-MailMessage -From $From -to $To -Subject $Subject `
	-Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
	-Credential $MailCred
	
	# Variables cleanup
	Remove-Variable -Name * -ErrorAction SilentlyContinue
	
	
	
	
	
	
КонецПроцедуры

ПодключитьСценарий("\\hpau.ts.local\git\1VirtualMachineManager\src\МенеджерВиртуальныхМашин.os","МенеджерВиртуальныхМашин");
Выгрузить();