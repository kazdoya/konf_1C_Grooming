﻿
&НаКлиенте
Процедура Вперед(Команда)
	УстановитьПредставлениеПериода("Вперед"); 
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	УстановитьПредставлениеПериода("Назад");
КонецПроцедуры

&НаКлиенте
Процедура Сегодня(Команда)
	УстановитьПредставлениеПериода("Сегодня") 
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗаполнитьПланировщикНаСервере();
	
	Если НЕ ЗначениеЗаполнено(ВариантПериода) Тогда
		ВариантПериода = "День";
	КонецЕсли;
	
	УстановитьОтображениеПланировщика();КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьПредставлениеПериода()
КонецПроцедуры


&НаСервере
Процедура УстановитьОтображениеПланировщика()
	
	НачалоРабочегоДня = Константы.НачалоРабочегоДня.Получить();
	ОкончаниеРабочегоДня =  Константы.ОкончаниеРабочегоДня.Получить();
	
	Планировщик.ОтображатьТекущуюДату = Истина;
	Планировщик.ОтступСНачалаПереносаШкалыВремени = НачалоРабочегоДня; //1
	Планировщик.ОтступСКонцаПереносаШкалыВремени = ?(ОкончаниеРабочегоДня = 0, 0, 24 - ОкончаниеРабочегоДня); //2
	Планировщик.ЕдиницаПериодическогоВарианта   = ТипЕдиницыШкалыВремени.Час; //3
	Планировщик.КратностьПериодическогоВарианта = 24;
	Планировщик.ВыравниватьГраницыЭлементовПоШкалеВремени = Ложь;
	Планировщик.ФорматПеренесенныхЗаголовковШкалыВремени = "ДФ='дддд, д ММММ гггг'";
	
КонецПроцедуры           


&НаСервере
Процедура ЗаполнитьПланировщикНаСервере()
	ЦветУслугаОказана = Новый Цвет(255, 153, 0);
	ЦветУслугаНеОказана = Новый Цвет(255, 237, 175);
	
	Запрос = Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ЗаписьКлиента.Сотрудник КАК Сотрудник,
	|	ЗаписьКлиента.Сотрудник.Представление КАК СотрудникПредставление,
	|	ЗаписьКлиента.ДатаЗаписи КАК ДатаЗаписи,
	|	ЗаписьКлиента.ДатаОкончанияЗаписи КАК ДатаОкончанияЗаписи,
	|	ЗаписьКлиента.Клиент.Представление КАК КлиентПредставление,
	|	ЗаписьКлиента.Ссылка КАК ЗаписьКлиента,
	|	ЗаписьКлиента.УслугаОказана КАК УслугаОказана,
	|	РеализацияТоваровИУслуг.ПризнакОплаты КАК ПризнакОплаты
	|ИЗ
	|	Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
	|		ПОЛНОЕ СОЕДИНЕНИЕ Документ.ЗаписьКлиента КАК ЗаписьКлиента
	|		ПО РеализацияТоваровИУслуг.Основание = ЗаписьКлиента.Ссылка
	|ГДЕ
	|	ЗаписьКлиента.Проведен
	|ИТОГИ ПО
	|	Сотрудник";
	
	ИзмеренияПланировщика = Планировщик.Измерения;
	ИзмеренияПланировщика.Очистить();
	

	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаСотрудники = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ИзмерениеСотрудники = ИзмеренияПланировщика.Добавить("Сотрудники"); // 1
	Пока ВыборкаСотрудники.Следующий() Цикл
		
		НовоеИзмерение = ИзмерениеСотрудники.Элементы.Добавить(ВыборкаСотрудники.Сотрудник); // 2
		НовоеИзмерение.Текст = ВыборкаСотрудники.СотрудникПредставление; // 3
		
		Выборка = ВыборкаСотрудники.Выбрать();
		Пока Выборка.Следующий() Цикл
			
			ДатаНачала = Выборка.ДатаЗаписи;
			ДатаОкончания = Выборка.ДатаОкончанияЗаписи;
			
			СоответствиеЗначений = Новый Соответствие; //4
			СоответствиеЗначений.Вставить("Сотрудники",   Выборка.Сотрудник);
			
			НовыйЭлемент = Планировщик.Элементы.Добавить(ДатаНачала, ДатаОкончания); // 5
			НовыйЭлемент.Текст = СокрЛП(Выборка.КлиентПредставление); //6
			ШиринаРамки = Новый Рамка(ТипРамкиЭлементаУправления.Одинарная, 2);
			НовыйЭлемент.Рамка = ШиринаРамки;
			НовыйЭлемент.Значение = Выборка.ЗаписьКлиента; //7
			Если Выборка.УслугаОказана Тогда //8
				НовыйЭлемент.ЦветФона  = ЦветУслугаОказана ;	
			Иначе
				НовыйЭлемент.ЦветФона  = ЦветУслугаНеОказана ;
			КонецЕсли;
			Если Выборка.ПризнакОплаты = Перечисления.ТипыОплатыДокумента.ПолностьюОплачен Тогда
				НовыйЭлемент.ЦветРамки = WebЦвета.Зеленый; 
			Иначе
				НовыйЭлемент.ЦветРамки = WebЦвета.Красный;
			КонецЕсли; 
			//НовыйЭлемент.ЦветРамки = WebЦвета.Черный;
			НовыйЭлемент.ЗначенияИзмерений  = Новый ФиксированноеСоответствие(СоответствиеЗначений); //9
			
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры   

&НаКлиенте
Процедура УстановитьПредставлениеПериода(Вариант = Неопределено)
	
	ТекущийПериод = Планировщик.ТекущиеПериодыОтображения[0]; // 1
	
	Если НЕ ЗначениеЗаполнено(ТекущийПериод.Начало) Тогда //2
		ТекущийПериод.Начало = ТекущаяДата();
	КонецЕсли;
	
	Планировщик.ТекущиеПериодыОтображения.Очистить(); //3
	
	Если ВариантПериода = "День" Тогда //4
		
		Если Вариант = Неопределено Тогда
			ДатаНачала = НачалоДня(ТекущийПериод.Начало);
		ИначеЕсли Вариант = "Назад" Тогда
			ДатаНачала = НачалоДня(ТекущийПериод.Начало) - 60 * 60 * 24;
		ИначеЕсли Вариант = "Вперед" Тогда
			ДатаНачала = НачалоДня(ТекущийПериод.Начало) + 60 * 60 * 24;
		ИначеЕсли Вариант = "Сегодня" Тогда
			ДатаНачала = НачалоДня(ТекущаяДата());
		КонецЕсли;
		
		ДатаОкончания  = КонецДня(ДатаНачала);
		Планировщик.ТекущиеПериодыОтображения.Добавить(ДатаНачала, ДатаОкончания); 
		
		ПредставлениеПериода = Формат(ДатаНачала, "ДФ='дд ММММ'");
		
	ИначеЕсли ВариантПериода = "Неделя" Тогда
		
		Если Вариант = Неопределено Тогда
			ДатаНачала = НачалоНедели(ТекущийПериод.Начало);
		ИначеЕсли Вариант = "Назад" Тогда
			ДатаНачала = НачалоНедели(ТекущийПериод.Начало) - 7 * 60 * 60 * 24;
		ИначеЕсли Вариант = "Вперед" Тогда
			ДатаНачала = НачалоНедели(ТекущийПериод.Начало) + 7 * 60 * 60 * 24;
		ИначеЕсли Вариант = "Сегодня" Тогда
			ДатаНачала = НачалоНедели(ТекущаяДата());
		КонецЕсли;
		
		ДатаОкончания  = КонецНедели(ДатаНачала);
		Планировщик.ТекущиеПериодыОтображения.Добавить(ДатаНачала, ДатаОкончания);
		
		ПредставлениеПериода = СтрШаблон("%1 - %2", Формат(ДатаНачала, "ДФ='дд ММММ'"), Формат(ДатаОкончания, "ДФ='дд ММММ гггг'"));
		
	ИначеЕсли ВариантПериода = "Месяц" Тогда
		
		Если Вариант = Неопределено Тогда
			ДатаНачала = НачалоМесяца(ТекущийПериод.Начало);
		ИначеЕсли Вариант = "Назад" Тогда
			ДатаНачала = ДобавитьМесяц(ТекущийПериод.Начало, -1);
		ИначеЕсли Вариант = "Вперед" Тогда
			ДатаНачала = ДобавитьМесяц(ТекущийПериод.Начало, 1);
		ИначеЕсли Вариант = "Сегодня" Тогда
			ДатаНачала = НачалоМесяца(ТекущаяДата());
		КонецЕсли;
		
		ДатаОкончания  = КонецМесяца(ДатаНачала);
		Планировщик.ТекущиеПериодыОтображения.Добавить(ДатаНачала, ДатаОкончания);
		
		ПредставлениеПериода = ПредставлениеПериода(ДатаНачала, ДатаОкончания);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВариантПериодаПриИзменении(Элемент)
	УстановитьПредставлениеПериода();
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикДелПриСменеТекущегоПериодаОтображения(Элемент, ТекущиеПериодыОтображения, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры 


&НаКлиенте
Процедура ПланировщикДелПередНачаломБыстрогоРедактирования(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПараметрыОткрытияФормы = Новый Структура("Ключ", Элемент.ВыделенныеЭлементы[0].Значение); //1
	
	ОткрытьФорму("Документ.ЗаписьКлиента.Форма.ФормаДокумента", ПараметрыОткрытияФормы,,ЭтаФорма); //2
	
КонецПроцедуры

&НаКлиенте
Процедура ПланировщикПередСозданием(Элемент, Начало, Конец, ЗначенияИзмерений, Текст, СтандартнаяОбработка)

СтандартнаяОбработка = Ложь;

ПараметрыОткрытияФормы = Новый Структура("Начало, Окончание, Сотрудник", Начало, Конец, ЗначенияИзмерений.Получить("Сотрудники"));

ОткрытьФорму("Документ.ЗаписьКлиента.Форма.ФормаДокумента",ПараметрыОткрытияФормы,,ЭтаФорма);

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "Записан заказ" Тогда
    Планировщик.Элементы.Очистить();
    ЗаполнитьПланировщикНаСервере();
КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	    Планировщик.Элементы.Очистить();
		ЗаполнитьПланировщикНаСервере();
КонецПроцедуры
