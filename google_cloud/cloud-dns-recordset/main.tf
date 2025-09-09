resource "google_dns_record_set" "cloud-static-records" {
  project      = var.project_id
  managed_zone = var.name

  for_each = var.enabled ? { for record in var.recordsets : join("/", [record.name, record.type]) => record } : {}
  name = (
    each.value.name != "" ?
    "${each.value.name}.${var.domain}" :
    var.domain
  )
  type = each.value.type
  ttl  = each.value.ttl

  rrdatas = each.value.records

  dynamic "routing_policy" {
    for_each = toset(each.value.routing_policy != null ? ["create"] : [])
    content {
      dynamic "wrr" {
        for_each = each.value.routing_policy.wrr
        iterator = wrr
        content {
          weight  = wrr.value.weight
          rrdatas = wrr.value.records
        }
      }

      dynamic "geo" {
        for_each = each.value.routing_policy.geo
        iterator = geo
        content {
          location = geo.value.location
          rrdatas  = geo.value.records
        }
      }
    }
  }
}
