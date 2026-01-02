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

    toggleDatePicker(event) {
        event.stopPropagation();
        this.isDatePickerOpen = !this.isDatePickerOpen;
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
}
