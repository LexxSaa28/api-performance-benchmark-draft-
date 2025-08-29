{
  port: 8125,
  backends: [ "./backends/graphite" ],
  graphite: {
    legacyNamespace: false,
    globalPrefix: "loadtest"
  }
}
