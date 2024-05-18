﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ДатаПрайсЛиста = ТекущаяДата();
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьДанныеЧерезтабличныйДокумент(Команда)
	СкопироватьФайлНаСервер("ТабличныйДокумент");
КонецПроцедуры

&НаКлиенте
Процедура СкопироватьФайлНаСервер(СпособЗагрузки)
	
	ОповещениеОЗавершении = Новый ОписаниеОповещения("СкопироватьФайлНаСерверЗавершение", ЭтотОбъект, СпособЗагрузки);
	НачатьПомещениеФайлаНаСервер(ОповещениеОЗавершении,,,,,УникальныйИдентификатор);
	
КонецПроцедуры  

&НаКлиенте
Процедура СкопироватьФайлНаСерверЗавершение(ОписаниеПомещенногоФайла, ДополнительныеПараметры) Экспорт
	
	Если ОписаниеПомещенногоФайла <> Неопределено Тогда
		
		АдресФайлаВХранилище = ОписаниеПомещенногоФайла.Адрес; //1
		
		ЗагрузитьИзТабличногоДокументаНаСервере(АдресФайлаВХранилище, ДатаПрайсЛиста, Поставщик, ДополнительныеПараметры); //2
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗагрузитьИзТабличногоДокументаНаСервере(АдресФайлаВХранилище, ДатаПрайсЛиста, Поставщик, ДополнительныеПараметры)
	
	ТабДок = ПрочитатьФайл(АдресФайлаВХранилище); //3
	Если ДополнительныеПараметры = "ТабличныйДокумент" Тогда
		ТаблицаПрайсЛиста = ЗаполнитьТаблицуЗначенийИзТабличногоДокумента(ТабДок); //8
	Конецесли;    
	
	Если ТаблицаПрайсЛиста.Количество() Тогда    
		ЗагрузитьПрайсЛистПоставщика(ТаблицаПрайсЛиста, ДатаПрайсЛиста, Поставщик);    //9
	Иначе
		СообщениеПользователю = Новый СообщениеПользователю();
		СообщениеПользователю.Текст = "Выбранный файл не содержит строк с ценами!";
		СообщениеПользователю.Сообщить();            
	КонецЕсли;    
	
КонецПроцедуры

&НаСервереБезКонтекста                            
Функция ПрочитатьФайл(АдресФайлаВХранилище)
	
	ТабДок = Новый ТабличныйДокумент;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла(".xlsx"); //4
	
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаВХранилище); //5
	ДвоичныеДанные.Записать(ИмяВременногоФайла); //6
	
	Попытка
		ТабДок.Прочитать(ИмяВременногоФайла); //7
	Исключение  
		вызватьИсключение "Не удалось прочитать файл EXCEL в табличный документ!";
	КонецПопытки; 
	
	возврат ТабДок;
	
КонецФункции      

&НаСервереБезКонтекста
Функция ЗаполнитьТаблицуЗначенийИзТабличногоДокумента(ТабДок)
	
	ТаблицаПрайсЛиста = Новый ТаблицаЗначений; //1
	
	ТаблицаПрайсЛиста.Колонки.Добавить("НомерСтроки", Новый ОписаниеТипов("Число"));;
	ТаблицаПрайсЛиста.Колонки.Добавить("Номенклатура",    Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(100)));
	ТаблицаПрайсЛиста.Колонки.Добавить("Артикул",    Новый ОписаниеТипов("Строка", Новый КвалификаторыСтроки(13)));
	ТаблицаПрайсЛиста.Колонки.Добавить("Цена",    Новый ОписаниеТипов("Число"));;
	
	КоличествоСтрок = табДок.ВысотаТаблицы; //2
	
	Для сч = 1 По КоличествоСтрок Цикл //3
		
		СтрокаПрайса = ТаблицаПрайсЛиста.Добавить();
		
		Попытка 
			СтрокаПрайса.НомерСтроки    = Строка(ТабДок.ПолучитьОбласть("R" + Формат(сч, "ЧГ=0;") + "C1").ТекущаяОбласть.Текст);
			СтрокаПрайса.Номенклатура    = Строка(ТабДок.ПолучитьОбласть("R" + Формат(сч, "ЧГ=0;") + "C2").ТекущаяОбласть.Текст);
			СтрокаПрайса.Артикул    = Строка(ТабДок.ПолучитьОбласть("R" + Формат(сч, "ЧГ=0;") + "C3").ТекущаяОбласть.Текст); //4
			СтрокаПрайса.Цена    = Число(ТабДок.ПолучитьОбласть("R" + Формат(сч, "ЧГ=0") + "C4").ТекущаяОбласть.Текст);
		Исключение
			вызватьИсключение "Не удалось прочитать файл EXCEL в табличный документ!";
		КонецПопытки;
		
	КонецЦикла;
	
	возврат ТаблицаПрайсЛиста;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ЗагрузитьПрайсЛистПоставщика(ТаблицаПрайсЛиста, ДатаПрайсЛиста, Поставщик)
	
	Запрос = Новый Запрос; //1
	Запрос.УстановитьПараметр("ТаблицаПрайсЛиста", ТаблицаПрайсЛиста);
	
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ТаблицаПрайсЛиста.НомерСтроки КАК НомерСтроки,
	|	ТаблицаПрайсЛиста.Номенклатура КАК Номенклатура,
	|	ТаблицаПрайсЛиста.Артикул КАК Артикул,
	|	ТаблицаПрайсЛиста.Цена КАК Цена
	|ПОМЕСТИТЬ ВТ_ТаблицаПрайсЛиста
	|ИЗ
	|	&ТаблицаПрайсЛиста КАК ТаблицаПрайсЛиста
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Ном.Ссылка КАК Номенклатура,
	|	ВТ_ТаблицаПрайсЛиста.Номенклатура КАК НоменклатураВТ,
	|	ВТ_ТаблицаПрайсЛиста.Артикул КАК Артикул,
	|	ВТ_ТаблицаПрайсЛиста.Цена КАК Цена
	|ИЗ
	|	ВТ_ТаблицаПрайсЛиста КАК ВТ_ТаблицаПрайсЛиста
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Ном
	|		ПО ВТ_ТаблицаПрайсЛиста.Артикул = Ном.Артикул";
	
	Рез = Запрос.Выполнить();
	Если Рез.Пустой() Тогда
		возврат;
	КонецЕсли;
	
	Выборка = Рез.Выбрать();
	
	ДокументУстановкиЦен = Документы.УстановкаЦенПоставщика.СоздатьДокумент(); //2
	ДокументУстановкиЦен.Контрагент = Поставщик;
	ДокументУстановкиЦен.Дата = ДатаПрайсЛиста;
	
	Пока Выборка.Следующий() Цикл
		НоваяСтрокаПрайса = ДокументУстановкиЦен.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрокаПрайса, Выборка);
	КонецЦикла;
	
	Попытка
		
		ДокументУстановкиЦен.Записать(РежимЗаписиДокумента.Проведение); //3
		
		СообщениеПользователю = Новый СообщениеПользователю();
		СообщениеПользователю.Текст = "Создан и проведен документ установки цен!";
		СообщениеПользователю.Сообщить();
		
	Исключение
		ДокументУстановкиЦен.Записать(); //4
		
		СообщениеПользователю = Новый СообщениеПользователю();
		СообщениеПользователю.Текст = "Произошла ошибка при проведении документа установки цен!";
		СообщениеПользователю.Сообщить();
		
	КонецПопытки;
	
Конецпроцедуры