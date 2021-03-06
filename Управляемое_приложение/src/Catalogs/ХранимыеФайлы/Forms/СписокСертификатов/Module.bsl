
&НаКлиенте
Перем СоответствиеСертификатов;
&НаКлиенте
Перем ПараметрыВыбора;
&НаКлиенте
Перем ВыбраныйСертификат;

//////////////////////////////////////////////////////////////////////////////// 
// Общие процедуры и функции 
// 

// определяет типы хранилищ сертификатов, сертификаты которых требуется поместить в список
// ПараметрыВыбора_Вход - список типов хранилищ сертификатов
&НаКлиенте
Процедура Установка(ПараметрыВыбора_Вход) Экспорт
	ПараметрыВыбора = ПараметрыВыбора_Вход;
КонецПроцедуры

// возвращает результаты выбора в форме
// - при множественном выборе - массив сертификатов
// - при единичном выборе - выбранный сертификат криптографии
&НаКлиенте
Функция ПолучитьРезультатВыбора()
	Если Параметры.МножественныйВыбор Тогда
		Вернуть = Новый Массив;
		Для Каждого СтрокаТаблициЗначений Из ТаблицаДляВыбора Цикл
			Если СтрокаТаблициЗначений.Выбран Тогда 
				Вернуть.Добавить(СоответствиеСертификатов[СтрокаТаблициЗначений]);
			КонецЕсли;
		КонецЦикла;
		Возврат Вернуть;
	Иначе
		Возврат ВыбраныйСертификат;
	КонецЕсли;
КонецФункции

//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ 
// 

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	СоответствиеСертификатов = Новый Соответствие;
	// Заполнение таблицы сертификатов
	МенеджерКриптографии = Новый МенеджерКриптографии();
	
	Оповещение = Новый ОписаниеОповещения(
		"ПолучитьСертификатыПослеСозданияМенеджераКриптографии",
		ЭтотОбъект);
	МенеджерКриптографии.НачатьИнициализацию(Оповещение, "", "", 75);
	
#Если НЕ МобильныйКлиент Тогда
	Элементы.ФормаПоказатьСписок.Видимость = Ложь;
#Иначе
	Элементы.ФормаПоказатьСписок.Видимость = Истина;
#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСертификатыПослеСозданияМенеджераКриптографии(МенеджерКриптографии, Контекст) Экспорт	
	
	// проверяем, что этим сертификатом файл еще не подписан
	
	Контекст = Новый Структура(
		"МенеджерКриптографии, ХранилищеПолучено", 
		МенеджерКриптографии, Новый Массив());	
	
	ПолучитьСледующееХранилищеСертификатов(, Контекст); 

КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСертификатыПослеЗакрытияСпискаСертификатов(Контекст) Экспорт	
	
	ТаблицаДляВыбора.Очистить();
	ПолучитьСледующееХранилищеСертификатов(, Контекст); 

КонецПроцедуры

&НаКлиенте
Процедура ПолучитьСледующееХранилищеСертификатов(Хранилище, Контекст) Экспорт	
	
	Если Хранилище <> Неопределено Тогда
		
		Контекст.ХранилищеПолучено.Добавить(Истина);
		
		Оповещение = Новый ОписаниеОповещения(
			"ПослеПолученияСертификатовХранилища",
			ЭтотОбъект, Контекст);		
		Хранилище.НачатьПолучениеВсех(Оповещение);		
		
	КонецЕсли;
	
	Если Контекст.ХранилищеПолучено.Количество() = ПараметрыВыбора.Количество() Тогда
		Возврат;
	КонецЕсли;
	
	ТекущееХраналище = ПараметрыВыбора[Контекст.ХранилищеПолучено.Количество()];
	
	Контекст2 =  Новый Структура(
		"МенеджерКриптографии, ХранилищеПолучено, Представление", 
		Контекст.МенеджерКриптографии, Контекст.ХранилищеПолучено, Строка(ТекущееХраналище));

	Оповещение = Новый ОписаниеОповещения(
		"ПолучитьСледующееХранилищеСертификатов",
		ЭтотОбъект, Контекст2);
	Контекст.МенеджерКриптографии.НачатьПолучениеХранилищаСертификатов(
		Оповещение, ТекущееХраналище.Значение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПолученияСертификатовХранилища(СертификатыХранилища, Контекст) Экспорт	
	ТекущаяДата = ТекущаяДата();
	Для Каждого Сертификат Из СертификатыХранилища Цикл
		Если Сертификат.ДатаОкончания < ТекущаяДата Тогда 
			Продолжить; // отфильтровываем истекшие сертификаты
		КонецЕсли;
		НоваяСтрока = ТаблицаДляВыбора.Добавить();
		СоответствиеСертификатов.Вставить(НоваяСтрока, Сертификат);
		НоваяСтрока.СертификатПредставление = Сертификат.Субъект.CN + НСтр("ru = ' выдан '", "ru") + Сертификат.Издатель.CN + НСтр("ru = ' действителен до '", "ru") + Сертификат.ДатаОкончания;
		НоваяСтрока.ТипХранилища = Контекст.Представление;
	КонецЦикла;
КонецПроцедуры	

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.МножественныйВыбор Тогда
		Элементы.ОсуществлениеВыбора.Видимость = Ложь;
		Заголовок = НСтр("ru = 'Список сертификатов получателей'", "ru");
	Иначе
		Элементы.КнопкаOK.КнопкаПоУмолчанию = Ложь;
		Элементы.ОсуществлениеВыбора.КнопкаПоУмолчанию = Истина;
		Элементы.КнопкаOK.Видимость = Ложь;
		Элементы.Отмена.Видимость = Ложь;
		Элементы.ТаблицаДляВыбораВыбран.Видимость = Ложь;
		Заголовок = НСтр("ru = 'Сертификат для создания подписи'", "ru");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаДляВыбораВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Не Параметры.МножественныйВыбор Тогда
		СтандартнаяОбработка = Ложь;
		Если Не ВыбраннаяСтрока = Неопределено Тогда 
			ВыбраныйСертификат = СоответствиеСертификатов[ ТаблицаДляВыбора[ВыбраннаяСтрока] ];
			Закрыть(ВыбраныйСертификат);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОсуществлениеВыбораНажатие(Команда)
	Если Не Параметры.МножественныйВыбор Тогда
		ТекущиеДанные = Элементы.ТаблицаДляВыбора.ТекущиеДанные;
		Если Не ТекущиеДанные = Неопределено Тогда 
			ВыбраныйСертификат = СоответствиеСертификатов[ ТекущиеДанные ];
			Закрыть(ВыбраныйСертификат);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура OK(Команда)
	Закрыть(ПолучитьРезультатВыбора());
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСписок(Команда)
	
#Если МобильныйКлиент Тогда 
	МенеджерКриптографии = Новый МенеджерКриптографии();
	
	Оповещение = Новый ОписаниеОповещения(
		"ПоказатьСписокСертификатовПослеСозданияМенеджераКриптографии",
		ЭтотОбъект);
	МенеджерКриптографии.НачатьИнициализацию(Оповещение, "", "", 1);
#КонецЕсли
	
КонецПроцедуры

#Если МобильныйКлиент Тогда 

&НаКлиенте
Процедура ПоказатьСписокСертификатовПослеСозданияМенеджераКриптографии(МенеджерКриптографии, Контекст) Экспорт	
	
	// проверяем, что этим сертификатом файл еще не подписан
	
	Контекст = Новый Структура(
		"МенеджерКриптографии, ХранилищеПолучено", 
		МенеджерКриптографии, Новый Массив());	
	
	Оповещение = Новый ОписаниеОповещения(
		"ПолучитьСертификатыПослеЗакрытияСпискаСертификатов",
		ЭтотОбъект,
		Контекст);
	МенеджерКриптографии.ПоказатьСписокСертификатов(Оповещение);

КонецПроцедуры

#КонецЕсли
