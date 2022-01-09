// Функция выполняет проверку того, что данные нужно переностить в данный узел
//
// Параметры:
//  Данные	– Объект, набор записей,... который нужно проверить.
//            То, что переносится везде, не обрабатывается
//  УзелОбмена - узел плана обмена, куда осуществляется перенос
//
// Возвращаемое значение:
//  Перенос - булево, если Истина - необходимо выполнять перенос, 
//			  иначе - перенос выполнять не нужно
//
Функция НуженПереносДанных(Данные, УзелОбмена) Экспорт
	
	Перенос = Истина;
    
#Если НЕ МобильныйАвтономныйСервер Тогда
    Если ТипЗнч(Данные) = Тип("ДокументОбъект.Заказ") Тогда
		
		// Проверяем, что автор документа - это текущий пользователь  
		Пользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
		Владелец = Справочники.Пользователи.НайтиПоКоду(Пользователь);
		Если Данные.Автор <> Владелец Тогда
			Перенос = Ложь;
        КонецЕсли;	
        
	КонецЕсли;
	
    Если ТипЗнч(Данные) = Тип("СправочникОбъект.Встречи") Тогда
		
		// Проверяем, что владелец - это текущий пользователь  
		Пользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
		Владелец = Справочники.Пользователи.НайтиПоКоду(Пользователь);
		Если Данные.Владелец <> Владелец Тогда
			Перенос = Ложь;
        КонецЕсли;	
        
    КонецЕсли;
    
    Если ТипЗнч(Данные) = Тип("РегистрСведенийНаборЗаписей.МобильныеОтчеты") Тогда
        
        // Проверяем, что запись предназначена для этого Получателя  
        Если Данные.Отбор.Получатель.Значение <> УзелОбмена.Код Тогда
        	Перенос = Ложь;
        КонецЕсли;	
        
	КонецЕсли;
#КонецЕсли
	
	Возврат Перенос;
	
КонецФункции

// Процедура записывает данные в формат XML
// Процедура анализирует переданный объект данных и на основе этого анализа
// записывает его определенным образом в формат XML
//
// Параметры:
//  ЗаписьXML	- объект, записывающий XML данные
//  Данные 		- данные, подлежащие записи в формат XML
//
Процедура ЗаписатьДанные(ЗаписьXML, Данные) Экспорт
    
    // В данном случае, нет данных, которые требуют нестандартной обработки
    // Записываем данные с помощью стандартного метода
    ЗаписатьXML(ЗаписьXML, Данные);
	
#Если МобильныйАвтономныйСервер Тогда
	Константы.ОтправленоЗаписей.Установить(Константы.ОтправленоЗаписей.Получить() + 1);
#КонецЕсли
	
КонецПроцедуры

// Функция читает данные из формат XML
// Процедура анализирует переданный объект ЧтениеXML и на основе этого анализа
// читает из него данные определенным образом
//
// Параметры:
//  ЧтениеXML	- объект, читающий XML данные
//
// Возвращаемое значение:
//  Данные - значение, прочитанное из объекта ЧтениеXML
//
Функция ПрочитатьДанные(ЧтениеXML) Экспорт
	
	// Пытаемся прочесть значение из объекта ЧтениеXML стандартным образом
	Данные = ПрочитатьXML(ЧтениеXML);
	
#Если НЕ МобильныйАвтономныйСервер Тогда
	// В мобильном приложении не всегда есть возможность надежно определить пользователя в списке
	// но в момент синхронизации пользователь известен
	Если ТипЗнч(Данные) = Тип("ДокументОбъект.Заказ") Тогда
		
		Если Данные.Автор.Пустая() Или Данные.Автор.ПолучитьОбъект() = Неопределено Тогда
			Пользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
			Владелец = Справочники.Пользователи.НайтиПоКоду(Пользователь);
			Данные.Автор = Владелец;
		КонецЕсли;	
		
	КонецЕсли;	
	Если ТипЗнч(Данные) = Тип("СправочникОбъект.Встречи") Тогда
		
		Если Данные.Автор.Пустая() Или Данные.Автор.ПолучитьОбъект() = Неопределено Тогда
			Пользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
			Владелец = Справочники.Пользователи.НайтиПоКоду(Пользователь);
			Данные.Автор = Владелец;
		КонецЕсли;	
		
	КонецЕсли;	
#Иначе
	Константы.ПринятоЗаписей.Установить(Константы.ПринятоЗаписей.Получить() + 1);
#КонецЕсли
	
	Возврат Данные;
	
КонецФункции

// Процедура регистрирует изменения, для всех данных, входящих в состав плана обмена
// Параметры:
//  УзелОбмена - узел плана обмена, для которого регистрируются изменения
Процедура ЗарегистрироватьИзмененияДанных(УзелОбмена) Экспорт

	СоставПланаОбмена = УзелОбмена.Метаданные().Состав;
    Для Каждого ЭлементСоставаПланаОбмена Из СоставПланаОбмена Цикл
        
        ПланыОбмена.ЗарегистрироватьИзменения(УзелОбмена,ЭлементСоставаПланаОбмена.Метаданные);
        
	КонецЦикла;

КонецПроцедуры

#Если НЕ МобильныйАвтономныйСервер Тогда
	
// Функция формирует отчет,
// используется для удаленного формирования из мобильного приложения 
//
// Параметры:
//  СтрокаНастроек - настройки формируемого отчета
//  ИнформацияРасшифровки - переменная, в которую будет записана информация расшифровки
//
// Возвращаемое значение:
//  сформированный табличный документ
//
Функция СформироватьОтчет(СтрокаНастроек, ИнформацияРасшифровки) Экспорт
    
    Настройки = Неопределено;
    Если СтрокаНастроек <> "" Тогда
        
        ЧтениеXML = Новый ЧтениеXML;
        ЧтениеXML.УстановитьСтроку(СтрокаНастроек);
        Настройки = СериализаторXDTO.ПрочитатьXML(ЧтениеXML, Тип("Структура"));
        
    Иначе
        Настройки = Новый Структура;
        
    КонецЕсли;
    
    Отчет = Отчеты.ОстаткиТоваровНаСкладах.Создать();
    
    ПараметрыВывода = Отчет.КомпоновщикНастроек.Настройки.ПараметрыВывода;
    ПараметрыВывода.УстановитьЗначениеПараметра("ГоризонтальноеРасположениеОбщихИтогов", РасположениеИтоговКомпоновкиДанных.Начало);
    ПараметрыВывода.УстановитьЗначениеПараметра("ВертикальноеРасположениеОбщихИтогов", РасположениеИтоговКомпоновкиДанных.Конец);
    ПараметрыВывода.УстановитьЗначениеПараметра("ВыводитьЗаголовок", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
    ПараметрыВывода.УстановитьЗначениеПараметра("ВыводитьПараметрыДанных", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
    ПараметрыВывода.УстановитьЗначениеПараметра("ВыводитьОтбор", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
    
    // Упрощение реализации, при желании эти настройки можно найти,
    // но мы знаем, что в отчете ОстаткиТоваровНаСкладах
    // "Товар" - вторая настройка,
    // "Склад" - третья настройка
    Элемент = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы[1];
    Товар = Неопределено;
    Настройки.Свойство("Товар", Товар);
    Если Товар <> Неопределено 
        И Товар <> Справочники.Товары.ПустаяСсылка() Тогда
        
        Элемент.Использование = Истина;
        Элемент.ПравоеЗначение = Товар;
        Если Товар.ЭтоГруппа Тогда
            
            Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСпискеПоИерархии;
            
        Иначе
            
            Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
            
        КонецЕсли;
        
    Иначе
        Элемент.Использование = Ложь;
        
    КонецЕсли;
    
	Если ПолучитьФункциональнуюОпцию("УчетПоСкладам") Тогда
	    Склад = Неопределено;
	    Настройки.Свойство("Склад", Склад);
	    Элемент = Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы[2];
	    Если Склад <> Неопределено 
	        И Склад <> Справочники.Склады.ПустаяСсылка() Тогда
	        
	        Элемент.Использование = Истина;
	        Элемент.ПравоеЗначение = Склад;
	        
	    Иначе
	        
	        Элемент.Использование = Ложь;
	        
	    КонецЕсли;
        
	КонецЕсли;
	
    ТабличныйДокумент = Новый ТабличныйДокумент();
	Настройки = Отчет.КомпоновщикНастроек.ПолучитьНастройки();
	ДанныеРасшифровки = Новый ДанныеРасшифровкиКомпоновкиДанных();
	МакетОформления = Отчет.ПолучитьМакет("ОформлениеДляМобильногоОтчета");
	
    КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
    МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(Отчет.СхемаКомпоновкиДанных, Настройки, ИнформацияРасшифровки, МакетОформления);

    ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
    ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных,, ДанныеРасшифровки, Истина);

    ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
    ПроцессорВывода.УстановитьДокумент(ТабличныйДокумент);
    ПроцессорВывода.НачатьВывод();
    ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
    ПроцессорВывода.ЗакончитьВывод();
	
	ИнформацияРасшифровки = Новый Соответствие;
	Для Каждого элемент из ДанныеРасшифровки.Элементы Цикл 
		Если ТипЗнч(элемент) = Тип("ЭлементРасшифровкиКомпоновкиДанныхПоля") Тогда
	        Поля = элемент.ПолучитьПоля();
	        Если Поля.Количество() > 0 Тогда
				ИнформацияРасшифровки.Вставить(элемент.Идентификатор, Поля[0].Значение); 
	        КонецЕсли;
	    КонецЕсли;
    КонецЦикла;
    Возврат ТабличныйДокумент;
    
КонецФункции

// Процедура формирует отчеты,
// удаленно заказанные мобильным приложением 
//
// Параметры:
//  УзелОбмена - узел плана обмена, для которого осуществляется формирование отчетов
//
Процедура СформироватьЗаказанныеОтчеты(УзелОбмена) Экспорт
    
    НаборЗаписей = РегистрыСведений.МобильныеОтчеты.СоздатьНаборЗаписей();
    НаборЗаписей.Отбор.Вид.Установить(Перечисления.ВидыМобильныхОтчетов.ОстаткиТоваровНаСкладах);
    НаборЗаписей.Отбор.Получатель.Установить(УзелОбмена.Код);
    НаборЗаписей.Прочитать();
    
    // в наборе с такими отборами не может быть больше одной записи
    Если НаборЗаписей.Количество() > 0 И НаборЗаписей[0].ОбновлятьПриОбмене = Истина Тогда
        
        ИнформацияРасшифровки = Неопределено;
        ТабличныйДокумент = СформироватьОтчет(НаборЗаписей[0].Настройки, ИнформацияРасшифровки);
        НаборЗаписей[0].Содержимое = Новый ХранилищеЗначения(ТабличныйДокумент);
        НаборЗаписей[0].Вид = Перечисления.ВидыМобильныхОтчетов.ОстаткиТоваровНаСкладах;
        НаборЗаписей[0].Получатель = УзелОбмена.Код;
	    ЗаписьXML = Новый ЗаписьXML;
	    ЗаписьXML.УстановитьСтроку();
        СериализаторXDTO.ЗаписатьXML(ЗаписьXML, ИнформацияРасшифровки);
        НаборЗаписей[0].ИнформацияРасшифровки = ЗаписьXML.Закрыть();
        НаборЗаписей.Записать();
        
    КонецЕсли;
    
КонецПроцедуры

#КонецЕсли
