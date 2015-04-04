# argo_b

AKA [argo-prod-b.stanford.edu](https://argo-prod-b.stanford.edu)

## Differentiation

`argo_b` is not `argo_dev`, because dev is for a smaller dataset with volatile frequent overwriting by developer code.

`argo_b` is not `argo_test`, because test is for manual testing of the application in a relatively stable setup (for mgmt).

`argo_b` is for the rebuilding of production data based on newer indexing code, later to be promoted to use in production Argo.  

Arguably test and dev might be compressed, but the main difference is that `argo_b` is essentially the "next" production index.  Others are not.
