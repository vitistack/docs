# Install Vitistack operator

The vitistack operator handles the vitistack crd object. The operator fetches information and adds it to the vitistack crd object, so other solutions could show or integrate with the vitistack. One example is ROR (Release Operate Report) found here: https://github.com/norskHelsenett/ror

Install the vitistack operator by:

```bash
helm install vitistack-operator oci://ghcr.io/vitistack/helm/vitistack-operator
```
