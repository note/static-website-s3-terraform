This is a Terraform project that creates Amazon S3 and Amazon Route 53 resources to host static website using a custom domain. It does exactly what [Amazon's guide](https://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html) does.

In case if guide, that this projects is implementing, changed I stored it as PDF in this repository too.

**Disclaimer**: At the moment of writing this project I am an absolute beginner to Terraform and I am definitely not an AWS expert. I've create it purely for my educational purpose but I thought it may be useful for some. Any suggestions/contributions are welcome.


## How to run it

There are 2 ways to run this project:

### 1. Interactive mode

FIrst was is to use interactive mode of providing input. Then all you need to do is to run the following command:

```
terraform apply
```

### 2. Use `*.tfvars` file

Take a look at `vars.tf` and for each input variable provide a value within e.g. `default.tfvars` file and run:

```
terraform apply -var-file="default.tfvars"
```


It's been tested with Terraform v0.11.3.