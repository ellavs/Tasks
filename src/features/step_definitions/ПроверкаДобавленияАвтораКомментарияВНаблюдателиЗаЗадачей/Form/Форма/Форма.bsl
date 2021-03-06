﻿//начало текста модуля

///////////////////////////////////////////////////
//Служебные функции и процедуры
///////////////////////////////////////////////////

&НаКлиенте
// контекст фреймворка Vanessa-Behavior
Перем Ванесса;
 
&НаКлиенте
// Структура, в которой хранится состояние сценария между выполнением шагов. Очищается перед выполнением каждого сценария.
Перем Контекст Экспорт;
 
&НаКлиенте
// Структура, в которой можно хранить служебные данные между запусками сценариев. Существует, пока открыта форма Vanessa-Behavior.
Перем КонтекстСохраняемый Экспорт;

&НаКлиенте
// Функция экспортирует список шагов, которые реализованы в данной внешней обработке.
Функция ПолучитьСписокТестов(КонтекстФреймворкаBDD) Экспорт
	Ванесса = КонтекстФреймворкаBDD;
	
	ВсеТесты = Новый Массив;
	
	Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,"ЯСталНаблюдателемЗаЗадачейСНомером(Парам01,Парам02)","ЯСталНаблюдателемЗаЗадачейСНомером","Тогда я стал наблюдателем за задачей ""ЭтоТестоваяЗадача"" с номером '9999999'");
	
	Возврат ВсеТесты;
КонецФункции
	
&НаСервере
// Служебная функция.
Функция ПолучитьМакетСервер(ИмяМакета)
	ОбъектСервер = РеквизитФормыВЗначение("Объект");
	Возврат ОбъектСервер.ПолучитьМакет(ИмяМакета);
КонецФункции
	
&НаКлиенте
// Служебная функция для подключения библиотеки создания fixtures.
Функция ПолучитьМакетОбработки(ИмяМакета) Экспорт
	Возврат ПолучитьМакетСервер(ИмяМакета);
КонецФункции



///////////////////////////////////////////////////
//Работа со сценариями
///////////////////////////////////////////////////

&НаКлиенте
// Процедура выполняется перед началом каждого сценария
Процедура ПередНачаломСценария() Экспорт
	СостояниеVanessaBehavior = Ванесса.ПолучитьСостояниеVanessaBehavior();
	ИмяСценария 			 = СостояниеVanessaBehavior.ТекущийСценарий.Имя;
	ПредставлениеСправочника = "узЗадачи";
	
	ЭлементСправочника = утвПолучитьЭлементГруппуСправочника(ПредставлениеСправочника, , "ЭтоТестоваяЗадача");
	утвУдалитьЭлементСправочника(ПредставлениеСправочника, ЭлементСправочника);
	
	СоздатьЭлементСправочникаСНаименованиеНаСервере(ПредставлениеСправочника, "ЭтоТестоваяЗадача");
	Задача = утвПолучитьЭлементГруппуСправочника(ПредставлениеСправочника, , "ЭтоТестоваяЗадача",,ИСТИНА);
		
	УстановитьЗначениеРеквизитаСправочника(Задача, "Код", 9999999);
	
	КонтекстСохраняемый.Вставить("Задача", Задача);
	
КонецПроцедуры

&НаКлиенте
// Процедура выполняется перед окончанием каждого сценария
Процедура ПередОкончаниемСценария() Экспорт
КонецПроцедуры

///////////////////////////////////////////////////
//Реализация шагов
///////////////////////////////////////////////////

&НаСервере
Процедура СоздатьЭлементСправочникаСНаименованиеНаСервере(ИмяСправочника, Наименование)
	ЭлементСправочника = Справочники[ИмяСправочника].СоздатьЭлемент();
	ЭлементСправочника.Наименование = Наименование;
	ЭлементСправочника.Записать();
КонецПроцедуры

&НаСервере
Функция утвПолучитьЭлементГруппуСправочника(ИмяСправочника, Код = "", Наименование = "", ИскатьГруппу = Ложь, ДолженБыть = ЛОЖЬ)
	ПредставлениеПоиска = "";
	
	Если Истина
		И ПустаяСтрока(Код)                      
		И ПустаяСтрока(Наименование)
		Тогда
		
		ВызватьИсключение "Не заполнено ни одно свойство поиска";
		
	ИначеЕсли Истина
		И ЗначениеЗаполнено(Код)
		И ЗначениеЗаполнено(Наименование)
		Тогда
		
		ПредставлениеПоиска = "коду """ + Код + """ и наименованию """ + Наименование + """";
		
	ИначеЕсли ЗначениеЗаполнено(Код) Тогда
		ПредставлениеПоиска = "коду """ + Код + """";
		
	ИначеЕсли ЗначениеЗаполнено(Наименование) Тогда
		ПредставлениеПоиска = "наименованию """ + Наименование + """";
		
	КонецЕсли;
	
	ТекстИсключения = "Не нашли #ГруппуИлиЭлемент справочника #ИмяСправочника по #ПредставлениеПоиска";
	
	ТекстИсключения = СтрЗаменить(ТекстИсключения, "#ГруппуИлиЭлемент"	 , ?(ИскатьГруппу, "группу", "элемент"));
	ТекстИсключения = СтрЗаменить(ТекстИсключения, "#ИмяСправочника"	 , ИмяСправочника);
	ТекстИсключения = СтрЗаменить(ТекстИсключения, "#ПредставлениеПоиска", ПредставлениеПоиска);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Справочник.Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Справочник
	|ГДЕ
	|	&МоиУсловия";
	
	ТекстМоиУсловия = "";
	
	Если ИскатьГруппу Тогда
		СформироватьТекстУсловияЗапроса(ТекстМоиУсловия, "Справочник.ЭтоГруппа = &ИскатьГруппу");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Код) Тогда
		СформироватьТекстУсловияЗапроса(ТекстМоиУсловия, "Справочник.Код = &Код");
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(Наименование) Тогда
		СформироватьТекстУсловияЗапроса(ТекстМоиУсловия, "Справочник.Наименование = &Наименование");
	КонецЕсли; 
	
	Если ПустаяСтрока(ТекстМоиУсловия) Тогда
		ТекстМоиУсловия = "ИСТИНА";
	КонецЕсли; 
	
	СтрокаЗаменыСправочника = "Справочник." + ИмяСправочника + " КАК Справочник";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&МоиУсловия", ТекстМоиУсловия);
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "Справочник.Пользователи КАК Справочник", СтрокаЗаменыСправочника);
	
	Запрос.УстановитьПараметр("ИскатьГруппу", ИскатьГруппу);
	Запрос.УстановитьПараметр("Код", Код);
	Запрос.УстановитьПараметр("Наименование", Наименование);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если ДолженБыть И РезультатЗапроса.Пустой() Тогда
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();

	Возврат ВыборкаДетальныеЗаписи.Ссылка;
КонецФункции

&НаСервере
Процедура СформироватьТекстУсловияЗапроса(ТекстРезультат, ТекстУсловия)
	Если НЕ ПустаяСтрока(ТекстРезультат) Тогда
		ТекстРезультат = ТекстРезультат + " И "
	КонецЕсли; 
	ТекстРезультат = ТекстРезультат + ТекстУсловия;
КонецПроцедуры

&НаСервере
Процедура утвУдалитьЭлементСправочника(ИмяСправочника, ЭлементСправочника)
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Справочник.Ссылка
	|ИЗ
	|	Справочник." + ИмяСправочника + " КАК Справочник
	|ГДЕ
	|	Справочник.Ссылка = &ЭлементСправочника";
	
	Запрос.УстановитьПараметр("ЭлементСправочника", ЭлементСправочника);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ЭлементОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		
		ЭлементОбъект.Удалить();
	КонецЦикла;
КонецПроцедуры


&НаСервере
Процедура УстановитьЗначениеРеквизитаСправочника(ЭлементСправочника, ИмяРеквизита, Значение, ЗначениеВХранилище = ЛОЖЬ)
	СпрОбъект = ЭлементСправочника.ПолучитьОбъект();
	Если ЗначениеВХранилище Тогда
		СпрОбъект[ИмяРеквизита] = Новый ХранилищеЗначения(Значение);
	Иначе
		СпрОбъект[ИмяРеквизита] = Значение;
	КонецЕсли;
	СпрОбъект.Записать();
КонецПроцедуры

&НаКлиенте
Функция ПолучитьАктивноеОкноИзТестовоеПриложение()
	Возврат КонтекстСохраняемый.ТестовоеПриложение.ПолучитьАктивноеОкно();
КонецФункции	

&НаКлиенте
Функция ПолучитьАктивноеОкноИзКонтекста()
	Возврат Контекст.АктивноеОкно;
КонецФункции	

&НаКлиенте
Функция НайтиПолеПоИмени(ИмяПоля,НужнаяФорма = Неопределено)
	Получилось = Ложь;
	Если Не Получилось Тогда
		Если НужнаяФорма = Неопределено Тогда
			ОкноПриложения         = ПолучитьАктивноеОкноИзТестовоеПриложение();
			НужнаяФорма           = ОкноПриложения.НайтиОбъект(Тип("ТестируемаяФорма"));
		КонецЕсли;	 
		
		Если НужнаяФорма = Неопределено Тогда
			//иногда 1С некорректно отдаёт текущее окно, тогда будем искать во всех окнах
			//сначала поищем в недавно открытом окне
			
			Попытка
				ОкноПриложения = ПолучитьАктивноеОкноИзКонтекста();
				НужнаяФорма    = ОкноПриложения.НайтиОбъект(Тип("ТестируемаяФорма"));
			Исключение
				
			КонецПопытки;
			
			//Если НужнаяФорма = Неопределено Тогда
			//	//затем будем искать во всех окнах
			//	МассивОкон = КонтекстСохраняемый.ТестовоеПриложение.НайтиОбъекты(Тип("ТестируемоеОкноКлиентскогоПриложения"));
			//	Для каждого ТекОкно Из МассивОкон Цикл
			//		
			//		НужнаяФорма    = ТекОкно.НайтиОбъект(Тип("ТестируемаяФорма"));
			//		Если НужнаяФорма <> Неопределено Тогда
			//			Контекст.Вставить("АктивноеОкно",ОкноПриложения); //произошла неявная смена активного окна
			//		КонецЕсли;	 
			//		
			//	КонецЦикла;
			//	
			//КонецЕсли;	 
		КонецЕсли;	 
		
		
		Если ИмяПоля = "" Тогда
			Поле = НужнаяФорма.НайтиОбъект(Тип("ТестируемоеПолеФормы"));
		Иначе	
			Поле = НужнаяФорма.НайтиОбъект(Тип("ТестируемоеПолеФормы"),,ИмяПоля);
		КонецЕсли;	 
		
	КонецЕсли;	 
	
	Возврат Поле;
КонецФункции	

&НаСервере
Процедура УстановитьЗначениеКонстаны(ИмяКонстанты, Результат)
	Константы[ИмяКонстанты].Установить(Результат);
КонецПроцедуры

&НаКлиенте
//Тогда я стал наблюдателем за задачей "ЭтоТестоваяЗадача" с номером '9999999'
//@ЯСталНаблюдателемЗаЗадачейСНомером(Парам01,Парам02)
Процедура ЯСталНаблюдателемЗаЗадачейСНомером(НаименованиеЗадачи, НомерЗадачи) Экспорт
	
	Результат = ПолучитьЗаписьРСПоЗадаче(КонтекстСохраняемый.Задача);
	
	Ванесса.ПроверитьНеРавенство(Неопределено, Результат, "Ожидаемое значение результата");
	Ванесса.ПроверитьРавенство(НаименованиеЗадачи, Результат.Наименование, "Ожидаемое значение наименования задачи");
	Ванесса.ПроверитьРавенство(НомерЗадачи, Результат.Номер, "Ожидаемое значение номера задачи");
	
КонецПроцедуры

Функция ПолучитьЗаписьРСПоЗадаче(Задача)
	
	Результат = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	узНаблюдателиЗаЗадачами.Задача.Наименование КАК Наименование,
	               |	узНаблюдателиЗаЗадачами.Задача.Код КАК Номер,
	               |	узНаблюдателиЗаЗадачами.Пользователь КАК Пользователь
	               |ИЗ
	               |	РегистрСведений.узНаблюдателиЗаЗадачами КАК узНаблюдателиЗаЗадачами
	               |ГДЕ
	               |	узНаблюдателиЗаЗадачами.Задача = &Задача
	               |	И узНаблюдателиЗаЗадачами.Пользователь = &Пользователь";
	
	Запрос.УстановитьПараметр("Задача", Задача);
	Запрос.УстановитьПараметр("Пользователь", Пользователи.ТекущийПользователь());
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		 Результат = Новый Структура("Наименование, Номер", Выборка.Наименование, Формат(Выборка.Номер,"ЧГ=0"));	
	КонецЕсли;	
	
	Возврат Результат;
	
КонецФункции	

//окончание текста модуля