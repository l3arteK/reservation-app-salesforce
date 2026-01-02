import { LightningElement } from "lwc";
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

    days = [];
    weeks = [];

    connectedCallback() {
        this.generateDays();
        this.buildWeeks();
        document.addEventListener("click", this.handleOutsideClick);
    }

    disconnectedCallback() {
        document.removeEventListener("click", this.handleOutsideClick);
    }

    handleOutsideClick = (event) => {
        if (!this.template.contains(event.target)) {
            this.isDatePickerOpen = false;
        }
    };

    renderedCallback() {
        if (this.isDatePickerOpen) {
            this.markToday();
        }
    }

    generateDays() {
        const daysInMonth = new Date(this.currentYear, this.currentMonth + 1, 0).getDate();

        this.days = Array.from({ length: daysInMonth }, (_, index) => ({
            day: index + 1
        }));
    }

    clearTodayMarker() {
        this.template.querySelectorAll(".slds-is-today").forEach((cell) => {
            cell.classList.remove("slds-is-today");
            cell.removeAttribute("aria-current");
        });
    }

    markToday() {
        this.clearTodayMarker();
        if (today.getMonth() !== this.currentMonth || today.getFullYear() !== this.currentYear) {
            return;
        }
        const todayCell = this.template.querySelector(`td[data-day="${today.getDate()}"]:not(.slds-day_adjacent-month)`);

        if (todayCell) {
            todayCell.classList.add("slds-is-today");
            todayCell.setAttribute("aria-current", "date");
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
                class: "slds-day_adjacent-month"
            });
        }

        for (let i = 1; i <= daysInMonth; i++) {
            days.push({
                day: i,
                class: ""
            });
        }

        while (days.length % 7 !== 0) {
            days.push({
                day: days.length - daysInMonth - firstDay + 1,
                class: "slds-day_adjacent-month"
            });
        }

        return days;
    }

    refreshCalendar() {
        this.generateDays();
        this.buildWeeks();
    }

    createDate(day) {
        return new Date(this.currentYear, this.currentMonth, day);
    }

    clearRangeStyles() {
        this.template.querySelectorAll("td").forEach((cell) => {
            cell.classList.remove("slds-is-selected", "slds-is-selected-multi");
            cell.setAttribute("aria-selected", "false");
        });
    }

    applyRangeStyles() {
        this.clearRangeStyles();

        if (!this.rangeStart) return;

        const cells = this.template.querySelectorAll("td:not(.slds-day_adjacent-month)");

        cells.forEach((cell) => {
            const day = Number(cell.dataset.day);
            const cellDate = this.createDate(day);

            if (this.rangeStart && !this.rangeEnd && cellDate.getTime() === this.rangeStart.getTime()) {
                cell.classList.add("slds-is-selected");
                cell.setAttribute("aria-selected", "true");
            }

            if (this.rangeStart && this.rangeEnd) {
                if (cellDate >= this.rangeStart && cellDate <= this.rangeEnd) {
                    cell.classList.add("slds-is-selected");
                    cell.setAttribute("aria-selected", "true");

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
        const mm = String(date.getMonth() + 1).padStart(2, "0");
        const dd = String(date.getDate()).padStart(2, "0");
        const yyyy = date.getFullYear();
        return `${mm}/${dd}/${yyyy}`;
    }

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

        if (event.currentTarget.classList.contains("slds-day_adjacent-month")) {
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

    get startDateValue() {
        return this.formatDate(this.rangeStart);
    }

    get endDateValue() {
        return this.formatDate(this.rangeEnd);
    }
}
