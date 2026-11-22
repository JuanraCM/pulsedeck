let stale = false;
const source = new EventSource('/events');
source.onopen = () => {
  if (stale) location.reload();
};
source.onerror = () => {
  stale = true;
  // CLOSED: the server answered with an error (invalid config). Show the error page.
  if (source.readyState === EventSource.CLOSED) location.reload();
};
source.onmessage = (event) => {
  const values = JSON.parse(event.data);
  for (const [id, value] of Object.entries(values)) {
    for (const el of document.querySelectorAll(`[data-metric="${id}"]`)) {
      el.textContent = value === null ? 'N/A' : `${value.toFixed(1)} ${el.dataset.unit}`;
    }
  }
  document.dispatchEvent(new CustomEvent('pulsedeck:values', { detail: values }));
};
