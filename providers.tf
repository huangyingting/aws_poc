provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "sydney"
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
