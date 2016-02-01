window.vtex = window.vtex or {}
window.vtex.i18n = window.vtex.i18n or {}

minicartLang =
  minicartPlugin:
    availableShippingOptions: "Available shipping options:"
    availableDays: "Available days:"
    chooseDate: "Choose a date"
    availableHour: "Available hour:"
    availableHours: "Available hours:"
    from: "From"
    to: "to"
    nextAvailableWindows: "Next available windows:"
    loading: "Loading..."
    of: "of"
    "Sun": "Sunday"
    "Mon": "Monday"
    "Tue": "Tuesday"
    "Wed": "Wednesday"
    "Thu": "Thursday"
    "Fri": "Friday"
    "Sat": "Saturday"
    "Jan": "January"
    "Feb": "February"
    "Mar": "March"
    "Apr": "April"
    "May": "May"
    "Jun": "June"
    "Jul": "July"
    "Aug": "August"
    "Sep": "September"
    "Oct": "October"
    "Nov": "November"
    "Dec": "December"

if window.vtex.i18n["en"]
  window.vtex.i18n["en"] = $.extend({}, window.vtex.i18n["en"], minicartLang)
else
  window.vtex.i18n["en"] = minicartLang
