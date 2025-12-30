import { LightningElement } from "lwc";
const today = new Date();

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
    }

    generateDays() {
        const daysInMonth = new Date(this.currentYear, this.currentMonth + 1, 0).getDate();

        this.days = Array.from({ length: daysInMonth }, (_, index) => ({
            day: index + 1
        }));
    }

    markToday() {
        if (today.getMonth() !== this.currentMonth || today.getFullYear() !== this.currentYear) {
            return;
        }

        const todayCell = this.template.querySelector(`[data-day="${today.getDate()}"]`);

        if (todayCell) {
            todayCell.classList.add("slds-is-today");
            todayCell.setAttribute("aria-current", "date");
        }
    }

    toggleDatePicker() {
        this.isDatePickerOpen = !this.isDatePickerOpen;
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

    get dateTimePickerClass() {
        return this.isDatePickerOpen
            ? "slds-form-element slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
            : "slds-form-element slds-dropdown-trigger slds-dropdown-trigger_click";
    }
}
