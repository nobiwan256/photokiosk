terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "nobiwan"
    workspaces {
      name = "photokiosk"
    }
  }

provider "aws" {
  region = "us-west-2"
  access_key = "ASIAXPJ3LA3OWTQRI727"
  secret_key = "ua9KS+WS2R9gcsCXATGY7O0Kw52TCipSgJQjbWz4"
  token      = "IQoJb3JpZ2luX2VjEAgaCXVzLXdlc3QtMiJHMEUCIFcQzivSK9N8TTOpOC16qh5CcTzpDEgZ3+rQiE3+dzbaAiEAnUtzQTL7B2QiSLcI1d/bkPhhnqpnsP/LXotMhsmxXEEqpgIIQRABGgw1MTM5MDk5MTc0MDUiDOBLhpfGuf7pCpqGKiqDAnx1f0vpKL9qAxtBJ3pKQqooKXOTN4Oer9fnRFMpDdFDk94Rkc6LKdaMj2tiMBlg+yORDI/aWX/KsI30Gl8PjUPqfWmhYh3OaVucghlnzO7+4a3FHa7VK6JXiAae4UGW2LU0Eye/A/4oIVxGadKoLMIdw/qJHcKFSa31+2WGleZuzOu4rpDFK8HD8Q+C8oNvHqVwU63QX/AWpc9+CZ/NtVAyX/gE+X6WaMCX3NxKUWb+1/Xv3wXiCM0844OAw1EnFl5RmsGqup56fIGmXur2qP2e9Xr66F28Me4McB1XIKUjYNE56bdTatAlt5L+pz2MK58ni9Dp0uNkaQqzBMjKG4gSgp8w9vX1vQY6nQFyXEgxRLB+1a9wGS95iwB3rISiIc8i4Kgumos5FYfDS0k51W89hUmB3LtMAp+ACekqBs6/3sH6gsAkpl2wD0fGLUm2zbgXjtgU4SKtc/LvLoT+KqtCU1oayjoND3I2W2sDazNAlqVDbtOXcux6PYF1SVvtnRMA2y4gNC4PiAac8QLm0cYDan4IeNg/m08LyuP1gyFuJnyBvd86wcGx"
}
