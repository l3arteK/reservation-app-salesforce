import { LightningElement, api } from "lwc";
const today = new Date();
const MONTH_NAMES = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
];

export default class CustomDatePicker extends LightningElement {
    isDatePickerOpen = false;

    currentMonth = today.getMonth();
    currentYear = today.getFullYear();
    currentDay;
    rangeStart;
    rangeEnd;
    _disabledDates;
    @api required = false;

    weeks = [];

    @api
    set disabledDates(dates) {
        this._disabledDates = dates;
        this.refreshCalendar();
    }

    get disabledDates() {
        return this._disabledDates;
    }

    @api checkValidity() {
        if (this.required) {
            return !!this.startDateValue && !!this.endDateValue;
        }
        return this.isValidRealDate(this.startDateValue) && this.isValidRealDate(this.endDateValue);
    }

    @api reportValidity() {
        this.reportValidityStartDate();
        this.reportValidityEndDate();
    }

    @api reset() {
        this.rangeStart = null;
        this.rangeEnd = null;
        this.refreshCalendar();
    }

    connectedCallback() {
        this.buildWeeks();
        document.addEventListener("click", this.handleOutsideClick);
    }

    disconnectedCallback() {
        document.removeEventListener("click", this.handleOutsideClick);
    }

    renderedCallback() {
        if (this.isDatePickerOpen) {
            this.markToday();
            this.applyRangeStyles();
        }
    }

    reportValidityStartDate() {
        this.validateDateInput("startDateValue");
    }

    reportValidityEndDate() {
        this.validateDateInput("endDateValue");
    }

    validateDateInput(fieldName) {
        const value = this[fieldName];
        const input = this.template.querySelector(`input[name="${fieldName}"]`);
        let error = "";

        if (!value) {
            error = "Completing this field is required.";
        } else if (!this.isValidRealDate(value)) {
            error = "Your entry does not match the allowed format: 01/06/2026";
        }

        input.setCustomValidity(error);
        input.reportValidity();

        if (!error) {
            const date = new Date(value);

            if (fieldName === "startDateValue") {
                this.rangeStart = date;
            } else {
                this.rangeEnd = date;
            }

            this.applyRangeStyles();
            this.emitChange();
        }
    }

    isValidRealDate(value) {
        const match = value.match(/^(0[1-9]|1[0-2])\/(0[1-9]|[12][0-9]|3[01])\/(\d{4})$/);

        if (!match) return false;

        const month = Number(match[1]);
        const day = Number(match[2]);
        const year = Number(match[3]);

        const date = new Date(year, month - 1, day);
        return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day;
    }

    isDateDisabled(date) {
        today.setHours(0, 0, 0, 0);

        const isPast = date < today;

        const isInDisabledList = this.disabledDates?.some((disabled) => {
            const d = new Date(disabled);
            return d.getFullYear() === date.getFullYear() && d.getMonth() === date.getMonth() && d.getDate() === date.getDate();
        });

        return isPast || isInDisabledList;
    }

    clearTodayMarker() {
        this.template.querySelectorAll(".slds-is-today").forEach((cell) => {
            cell.classList.remove("slds-is-today");
        });
    }

    markToday() {
        this.clearTodayMarker();
        if (today.getMonth() !== this.currentMonth || today.getFullYear() !== this.currentYear) {
            return;
        }
        const todayCell = this.template.querySelector(`td[data-day="${today.getDate()}"]:not(.slds-disabled-text)`);

        if (todayCell) {
            todayCell.classList.add("slds-is-today");
        }
    }

    buildWeeks() {
        const flatDays = this.buildCalendarDays();
        const weeks = [];

        for (let i = 0; i < flatDays.length; i += 7) {
            weeks.push(flatDays.slice(i, i + 7));
        }
        this.weeks = weeks;
    }

    buildCalendarDays() {
        const firstDay = new Date(this.currentYear, this.currentMonth, 1).getDay();
        const daysInMonth = new Date(this.currentYear, this.currentMonth + 1, 0).getDate();
        const daysInPrevMonth = new Date(this.currentYear, this.currentMonth, 0).getDate();

        const days = [];

        for (let i = firstDay - 1; i >= 0; i--) {
            days.push({
                day: daysInPrevMonth - i,
                class: "slds-disabled-text"
            });
        }

        for (let i = 1; i <= daysInMonth; i++) {
            const date = new Date(this.currentYear, this.currentMonth, i);
            const isDisabled = this.isDateDisabled(date);
            days.push({
                day: i,
                class: isDisabled ? "slds-disabled-text" : ""
            });
        }

        while (days.length % 7 !== 0) {
            days.push({
                day: days.length - daysInMonth - firstDay + 1,
                class: "slds-disabled-text"
            });
        }

        return days;
    }

    refreshCalendar() {
        this.buildWeeks();
    }

    createDate(day) {
        return new Date(this.currentYear, this.currentMonth, day);
    }

    clearRangeStyles() {
        this.template.querySelectorAll("td").forEach((cell) => {
            cell.classList.remove("slds-is-selected", "slds-is-selected-multi");
        });
    }

    applyRangeStyles() {
        this.clearRangeStyles();

        if (!this.rangeStart || !(this.rangeStart instanceof Date)) return;

        const cells = this.template.querySelectorAll("td:not(.slds-disabled-text)");

        cells.forEach((cell) => {
            const day = Number(cell.dataset.day);
            const cellDate = this.createDate(day);

            if (this.rangeStart && !this.rangeEnd && cellDate.getTime() === this.rangeStart.getTime()) {
                cell.classList.add("slds-is-selected");
            }

            if (this.rangeStart && this.rangeEnd instanceof Date) {
                if (cellDate >= this.rangeStart && cellDate <= this.rangeEnd) {
                    cell.classList.add("slds-is-selected");

                    if (cellDate.getTime() === this.rangeStart.getTime() || cellDate.getTime() === this.rangeEnd.getTime()) {
                        cell.classList.add("slds-is-selected-multi");
                    }
                }
            }
        });
    }

    toggleDatePicker(event) {
        event.stopPropagation();
        this.isDatePickerOpen = !this.isDatePickerOpen;
    }

    formatDate(date) {
        if (!date) return "";
        if (!(date instanceof Date)) return date;
        const mm = String(date.getMonth() + 1).padStart(2, "0");
        const dd = String(date.getDate()).padStart(2, "0");
        const yyyy = date.getFullYear();
        return `${mm}/${dd}/${yyyy}`;
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value;

        if (name === "startDateValue") {
            this.reportValidityStartDate();
        }
        if (name === "endDateValue") {
            this.reportValidityEndDate();
        }
    }

    handleOutsideClick = (event) => {
        if (!this.template.contains(event.target)) {
            this.isDatePickerOpen = false;
        }
    };

    handleYearChange(event) {
        event.stopPropagation();
        this.currentYear = Number(event.target.value);
        this.refreshCalendar();
    }
    handleYearClick(event) {
        event.stopPropagation();
    }

    handlePrevMonth(event) {
        event.stopPropagation();
        if (this.currentMonth === 0) {
            this.currentMonth = 11;
            this.currentYear--;
        } else {
            this.currentMonth--;
        }

        this.refreshCalendar();
    }

    handleNextMonth(event) {
        event.stopPropagation();
        if (this.currentMonth === 11) {
            this.currentMonth = 0;
            this.currentYear++;
        } else {
            this.currentMonth++;
        }

        this.refreshCalendar();
    }

    handleDayClick(event) {
        event.stopPropagation();

        const day = Number(event.currentTarget.dataset.day);

        if (event.currentTarget.classList.contains("slds-disabled-text")) {
            return;
        }

        const clickedDate = this.createDate(day);

        if (!this.rangeStart || (this.rangeStart && this.rangeEnd)) {
            this.rangeStart = clickedDate;
            this.rangeEnd = null;
        } else if (clickedDate < this.rangeStart) {
            this.rangeStart = clickedDate;
            this.rangeEnd = null;
        } else {
            this.rangeEnd = clickedDate;
        }

        this.applyRangeStyles();
        this.emitChange();
    }

    emitChange() {
        this.dispatchEvent(
            new CustomEvent("change", {
                detail: {
                    startDate: this.formatDateISO(this.rangeStart),
                    endDate: this.formatDateISO(this.rangeEnd)
                }
            })
        );
    }

    formatDateISO(date) {
        if (!date) return null;

        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, "0");
        const day = String(date.getDate()).padStart(2, "0");

        return `${year}-${month}-${day}`;
    }

    get dateTimePickerClass() {
        return this.isDatePickerOpen
            ? "slds-form-element slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
            : "slds-form-element slds-dropdown-trigger slds-dropdown-trigger_click";
    }

    get currentMonthLabel() {
        return MONTH_NAMES[this.currentMonth];
    }

    get yearOptions() {
        const current = today.getFullYear();
        const years = [];

        for (let i = current - 5; i <= current + 5; i++) {
            years.push({ label: i, value: i });
        }
        return years;
    }

    set startDateValue(value) {
        this.rangeStart = value;
    }

    set endDateValue(value) {
        this.rangeEnd = value;
    }

    get startDateValue() {
        return this.formatDate(this.rangeStart);
    }

    get endDateValue() {
        return this.formatDate(this.rangeEnd);
    }
}
