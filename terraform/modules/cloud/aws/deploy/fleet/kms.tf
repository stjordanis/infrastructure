resource "aws_kms_key" "key" {
  description = "${data.aws_region.current.name}-kms"
}

data "aws_kms_ciphertext" "secret" {
  key_id    = "${aws_kms_key.key.key_id}"
  plaintext = "${var.datadog_api_key}"
}
