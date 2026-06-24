---
sidebar_position: 6
---

# 🚚 The story behind helm-gitlab

helm-gitlab didn't start as a chart. It started as a migration: moving an entire self-hosted
GitLab to another cloud — and then **proving the move was lossless, byte for byte**.

Pulling that off meant treating every backing service as something you own and can verify, not a
black box: an in-cluster **PostgreSQL HA** pair you can checksum, **SeaweedFS** object storage you
control, **Valkey**, and **Traefik** routing — all reproducible from source. This chart is the
generalized, cleaned-up result of that work, so the next person doesn't have to rediscover the
hard parts.

## 📖 Read the full write-up

The complete account — *"The day I moved our entire GitLab to another cloud and proved I didn't
lose a single byte"* by Shane Froebel — is on Medium:

👉 **[Read it on Medium](https://medium.com/@shane.froebel/the-day-i-moved-our-entire-gitlab-to-another-cloud-and-proved-i-didnt-lose-a-single-byte-fcf4a838eb9c)**

If you're evaluating whether to run your own GitLab this way, that story is the *why* behind every
design decision documented here.
