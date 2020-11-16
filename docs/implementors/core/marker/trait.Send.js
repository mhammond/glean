(function() {var implementors = {};
implementors["glean"] = [{"text":"impl Send for Configuration","synthetic":true,"types":[]},{"text":"impl Send for ClientInfoMetrics","synthetic":true,"types":[]},{"text":"impl Send for HttpUploader","synthetic":true,"types":[]},{"text":"impl Send for BooleanMetric","synthetic":true,"types":[]},{"text":"impl Send for CounterMetric","synthetic":true,"types":[]},{"text":"impl Send for PingType","synthetic":true,"types":[]},{"text":"impl Send for RecordedExperimentData","synthetic":true,"types":[]}];
implementors["glean_core"] = [{"text":"impl Send for CommonMetricData","synthetic":true,"types":[]},{"text":"impl Send for Error","synthetic":true,"types":[]},{"text":"impl Send for Configuration","synthetic":true,"types":[]},{"text":"impl Send for Glean","synthetic":true,"types":[]},{"text":"impl Send for Lifetime","synthetic":true,"types":[]},{"text":"impl Send for ErrorKind","synthetic":true,"types":[]},{"text":"impl Send for ErrorType","synthetic":true,"types":[]},{"text":"impl Send for RecordedEvent","synthetic":true,"types":[]},{"text":"impl Send for HistogramType","synthetic":true,"types":[]},{"text":"impl Send for BooleanMetric","synthetic":true,"types":[]},{"text":"impl Send for CounterMetric","synthetic":true,"types":[]},{"text":"impl Send for CustomDistributionMetric","synthetic":true,"types":[]},{"text":"impl Send for DatetimeMetric","synthetic":true,"types":[]},{"text":"impl Send for EventMetric","synthetic":true,"types":[]},{"text":"impl Send for JweMetric","synthetic":true,"types":[]},{"text":"impl&lt;T&gt; Send for LabeledMetric&lt;T&gt; <span class=\"where fmt-newline\">where<br>&nbsp;&nbsp;&nbsp;&nbsp;T: Send,&nbsp;</span>","synthetic":true,"types":[]},{"text":"impl Send for MemoryDistributionMetric","synthetic":true,"types":[]},{"text":"impl Send for PingType","synthetic":true,"types":[]},{"text":"impl Send for QuantityMetric","synthetic":true,"types":[]},{"text":"impl Send for StringMetric","synthetic":true,"types":[]},{"text":"impl Send for StringListMetric","synthetic":true,"types":[]},{"text":"impl Send for TimespanMetric","synthetic":true,"types":[]},{"text":"impl Send for TimingDistributionMetric","synthetic":true,"types":[]},{"text":"impl Send for UuidMetric","synthetic":true,"types":[]},{"text":"impl Send for DistributionData","synthetic":true,"types":[]},{"text":"impl Send for MemoryUnit","synthetic":true,"types":[]},{"text":"impl Send for TimeUnit","synthetic":true,"types":[]},{"text":"impl Send for Metric","synthetic":true,"types":[]},{"text":"impl Send for PingMaker","synthetic":true,"types":[]},{"text":"impl Send for StorageManager","synthetic":true,"types":[]},{"text":"impl Send for PingRequest","synthetic":true,"types":[]},{"text":"impl Send for PingUploadManager","synthetic":true,"types":[]},{"text":"impl Send for UploadResult","synthetic":true,"types":[]},{"text":"impl Send for PingUploadTask","synthetic":true,"types":[]}];
implementors["glean_ffi"] = [{"text":"impl&lt;'a&gt; !Send for FfiConfiguration&lt;'a&gt;","synthetic":true,"types":[]},{"text":"impl !Send for ByteBuffer","synthetic":true,"types":[]},{"text":"impl !Send for FfiPingUploadTask","synthetic":true,"types":[]}];
if (window.register_implementors) {window.register_implementors(implementors);} else {window.pending_implementors = implementors;}})()