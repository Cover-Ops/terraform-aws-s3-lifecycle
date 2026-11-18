# S3 lifecycle and Intelligent-Tiering

A CoverOps Marketplace kit. Most S3 bills carry three silent costs: objects nobody reads at the full Standard price, old versions kept forever, and unfinished multipart uploads that never show up as objects. This kit puts lifecycle rules on the buckets you name to stop all three. Terraform ≥ 1.6 or OpenTofu ≥ 1.6, AWS provider 6.x. Apache 2.0.

> Status: **v0.1.0, tested on 2026-11-18**: applied, re-planned with no changes and destroyed on a sandbox AWS account (ap-south-1), nothing left behind. Run `terraform plan` before you apply it to your account.

## What it creates

| Resource | Why | Cost |
|---|---|---|
| S3 lifecycle configuration per bucket you name | Applies the rules below; it replaces any lifecycle rules the bucket already has | Free |
| Rule: objects over 128 KB to Intelligent-Tiering | Objects nobody reads drop to cheaper tiers by themselves, with no retrieval fee | Monitoring fee: US$0.0025 per 1,000 objects a month (list price) |
| Rule: delete old versions after 30 days | Versioned buckets stop growing forever | Free |
| Rule: remove unfinished multipart uploads after 7 days | Billed parts you cannot see are cleared | Free |

**Estimated monthly cost: ₹0** (estimate, at AWS list prices). Lifecycle rules are free. Intelligent-Tiering adds a small per-object monitoring fee and saves on objects not read for 30 days or more.

## Mandatory tags
The kit's `tags` output is `Project`, `Environment`, `Owner`, `CostCentre`, `ManagedBy` and `Kit`. Put the same tags in your provider's `default_tags` (see the example) so everything you create carries them. The CoverOps Platform reads these tags to say who owns each rupee.

## Use

```hcl
module "s3_lifecycle" {
  source = "github.com/Cover-Ops/terraform-aws-s3-lifecycle?ref=v0.1.0"

  project      = "acme"
  environment  = "production"
  owner        = "platform@acme.example"
  bucket_names = ["acme-assets"]
}
```

Full example: [`examples/basic`](examples/basic).

## Inputs

| Name | Description | Default |
|---|---|---|
| `project` | Short name of the product or company, used in names and the Project tag (lowercase, digits, hyphens). | required |
| `environment` | Which environment the buckets belong to: production, staging or development. | required |
| `owner` | Who answers for spend on these buckets: a team or a person's email. Goes in the Owner tag. | required |
| `cost_centre` | Cost centre or budget line for the CostCentre tag, e.g. engineering. | `engineering` |
| `bucket_names` | Buckets to manage. The kit REPLACES any lifecycle rules these buckets already have. | required |
| `intelligent_tiering` | Move objects to S3 Intelligent-Tiering, which lowers the price of objects nobody reads, with no retrieval fee. | `true` |
| `noncurrent_version_days` | Delete old (noncurrent) object versions this many days after they were replaced. 0 keeps them forever. | `30` |
| `abort_multipart_days` | Remove unfinished multipart uploads after this many days. They are billed but never show up as objects. | `7` |
| `expire_prefixes` | Delete objects under these prefixes after the given number of days, e.g. { "tmp/" = 7, "logs/" = 90 }. | `{}` |
| `extra_tags` | More tags for the tags output. | `{}` |

## Outputs
`tags`, `bucket_names`.

## Good to know
- **It replaces a bucket's existing lifecycle rules.** Look at Management → Lifecycle rules on each bucket first, and add what you need to keep through `expire_prefixes` or keep that bucket out.
- Objects under 128 KB are left in their current class: S3 does not tier them, and they would only add monitoring fees.
- Old versions are deleted 30 days after being replaced (`noncurrent_version_days`); set 0 to keep them, e.g. for a backup bucket.
- Intelligent-Tiering has no retrieval fee, but objects move down only after 30 days without access, so savings show from the second month.

## Support
Open an issue on GitHub. Want CoverOps engineers to apply it for you? See the setup service on marketplace.coverops.dev.
