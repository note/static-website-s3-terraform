# For readability purposes most of the resources are commented with sections number of the guide they refer to.
# By "the guide" this document https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html is meant
# You can also find version of the document the author used attached as PDF to this repo

provider "aws" {
  profile = "${var.aws_profile_name}"
  region     = "eu-central-1"
}

# Step 2.1: Create Two Buckets
data "template_file" "policy_template" {
  # Content of policy.tpl copied from the guide
  template = "${file("templates/policy.tpl")}"

  vars {
    domain = "${var.site_domain}"
  }
}

data "template_file" "policy_template_www" {
  template = "${file("templates/policy.tpl")}"

  vars {
    domain = "www.${var.site_domain}"
  }
}

locals {
  index_document = "index.html"
  error_document = "error.html"
}

# Step 2.1: Create Two Buckets
resource "aws_s3_bucket" "website" {
  bucket = "${var.site_domain}"
  acl    = "public-read"

  policy = "${data.template_file.policy_template.rendered}"

  # Step 2.2: Configure Buckets for Website Hosting
  website {
    index_document = "${local.index_document}"
    error_document = "${local.error_document}"
  }
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_domain}"
  acl    = "public-read"

  policy = "${data.template_file.policy_template_www.rendered}"

  # Step 2.3: Configure Your Website Redirect
  website {
    redirect_all_requests_to = "${var.site_domain}"
  }
}

resource "aws_s3_bucket_object" "index_page" {
  bucket = "${aws_s3_bucket.website.bucket}"
  key    = "${local.index_document}"
  source = "templates/${local.index_document}"
  etag   = "${md5(file("templates/${local.index_document}"))}"
  content_type    = "text/html"
}

resource "aws_s3_bucket_object" "error_page" {
  bucket = "${aws_s3_bucket.website.bucket}"
  key    = "${local.error_document}"
  source = "templates/${local.error_document}"
  etag   = "${md5(file("templates/${local.error_document}"))}"
  content_type    = "text/html"
}

# Step 3.1: Create a Hosted Zone for Your Domain
resource "aws_route53_zone" "primary" {
  name = "${var.site_domain}"
}

# Step 3.2: Add Alias Records for example.com and www.example.com
resource "aws_route53_record" "website_alias" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.site_domain}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.website.website_domain}"
    zone_id                = "${aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.${var.site_domain}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.www.website_domain}"
    zone_id                = "${aws_s3_bucket.www.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# Step 3.3: Transfer Other DNS Records from Your Current DNS Provider to Route 53
resource "aws_route53_record" "mx_records" {
  count   = "${length(var.mx_records) > 0 ? 1 : 0}"

  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "original_mx_records"
  type    = "MX"
  ttl     = "${var.ttl}"

  records = "${var.mx_records}"
}

resource "aws_route53_record" "cname-records" {
  count   = "${length(var.cname_records) > 0 ? 1 : 0}"

  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "original_cname_records"
  type    = "CNAME"
  ttl     = "${var.ttl}"

  records = "${var.cname_records}"
}

