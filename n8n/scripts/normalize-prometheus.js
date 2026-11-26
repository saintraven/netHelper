// Вставь в n8n Code node «Normalize monitoring event v1.0»
const targetId = $env.TARGET_ID || 'edge-router-01';
const prom = $input.first().json;
const ok = prom?.status === 'success';
const rows = ok ? prom.data?.result || [] : [];
const row =
  rows.find((r) => r.metric?.target_id === targetId) || rows[0] || null;
const metric = row?.metric || {};

const num = (v) => {
  if (v === undefined || v === null) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
};
const probeSuccess = row?.value ? num(row.value[1]) : null;

const iso = (d) => d.toISOString().replace(/\.\d{3}Z$/, 'Z');
const now = new Date();
const missing = [];
if (probeSuccess === null) missing.push('probe_success');

const dataStatus = !ok
  ? 'unavailable'
  : missing.length
    ? 'partial'
    : 'complete';

const event = {
  schema_version: '1.0',
  event_id: `evt-${Date.now()}`,
  observed_at: iso(now),
  window: {
    from: iso(new Date(now.getTime() - 5 * 60 * 1000)),
    to: iso(now),
  },
  target: {
    target_id: metric.target_id || targetId,
    instance: metric.instance || '',
    environment: metric.environment || 'production',
    job: metric.job || 'blackbox-http',
    module: metric.module || 'http_2xx',
  },
  metrics: {
    probe_success: { value: probeSuccess, unit: 'boolean' },
    probe_duration_seconds: { value: null, unit: 'seconds' },
    probe_http_status_code: { value: null, unit: 'code' },
  },
  data_quality: {
    status: dataStatus,
    missing_metrics: missing,
    prometheus_status: prom?.status || 'error',
  },
};

return [{ json: event }];