provider "github" {
    token = "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"
}

resource "github_repository" "terraform-first-repo" {
    name        = "first-repo-from-terraform"
    description = "my first resource from terraform created using script"
    visibility = "public"
    auto_init = true
}