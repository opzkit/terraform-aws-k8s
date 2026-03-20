resource "aws_cloudwatch_log_group" "node_bootstrap" {
  count             = var.node_cloudwatch_logging.enabled ? 1 : 0
  name              = "${var.node_cloudwatch_logging.log_group}/${var.name}"
  retention_in_days = var.node_cloudwatch_logging.retention
}
