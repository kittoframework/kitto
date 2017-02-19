export default {
  updatedAt: function(value) {
    if (!value) { return; }

    let timestamp = new Date(value * 1000);
    let hours = timestamp.getHours();
    let minutes = ("0" + timestamp.getMinutes()).slice(-2);
    let seconds = ("0" + timestamp.getSeconds()).slice(-2);

    return `Last updated at ${hours}:${minutes}:${seconds}`;
  },
  shortenedNumber: function(num) {
    if (isNaN(num)) { return num; }
    if (num >= 1000000000) { return (num / 1000000000).toFixed(1) + 'B'; }
    if (num >= 1000000) { return (num / 1000000).toFixed(1) + 'M'; }
    if (num >= 1000) { return (num / 1000).toFixed(1) + 'K'; }

    return num;
  },
  prettyNumber: function(num) {
    return isNaN(num) ? '' : num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  },
  prepend: function(value, string) {
    return (string != null ? string : '') + (value != null ? value : '');
  },
  append: function(value, string) {
    return (value != null ? value : '') + (string != null ? string : '');
  },
  truncate: function(text, limit, omission) {
    if (!(typeof text === 'string')) { text = text + ""; }
    if (!(typeof limit === 'number') || isNaN(limit)) { limit = 30; }
    if (!(typeof omission === 'string')) { omission = '…'; }

    if (text.length <= limit) { return text; }

    return `${text.substr(0, limit)}${omission}`;
  }
};
