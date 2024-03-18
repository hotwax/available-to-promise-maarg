# available-to-proimse

Available to Promise refers to the capability to determine the quantity of a product that can be promised to a customer at a specific point in time based on the current inventory levels, existing orders, and any other constraints or factors affecting availability.

## Key Components

1. **ATP Rules and Conditions:** Establishing rules and conditions that dictate how threshold, safety stock and shipping should be handled for a product in a facility based on various factors such as tags, product features etc.
2. **ATP Rule Groups:** Organizing rules into groups, allowing for better execution of one rule set e.g. setting threshold, safety stock or shipping for all the matching products.

Effective managing of threshold, safety stocks, shipping etc. contributes to managing product atp more accurately.


# Login Instructions

This document provides instructions on how to authenticate using the login API and how to use the received credentials for subsequent API calls.

## Logging In

1. **Endpoint**: To log in, make a POST request to the following endpoint: `http://localhost:8080/rest/login`.

2. **Request Format**: The request should be made with the `Content-Type` header set to `application/x-www-form-urlencoded`. The body of the request must include the following parameters:
    - `username`: Your username.
    - `password`: Your password.

   Example using `curl`:
   ```bash
   curl -X POST http://localhost:8080/rest/login \
   -H 'Content-Type: application/x-www-form-urlencoded' \
   -d 'username=YOUR_USERNAME&password=YOUR_PASSWORD'

**Successful Response**: Upon successful authentication, the API will return the following JSON response:

```json
{
  "loggedIn": true
}
```
## Retrieving the CSRF Token and Cookie

- **CSRF Token**: The response will include an `X-CSRF-Token` in the headers. This token is required for making subsequent API calls.
- **Cookie**: The response also sets a session cookie. Ensure that your HTTP client is configured to store and use cookies for subsequent requests.

### Example of extracting the CSRF token using curl

Assuming the use of a tool like `jq` to parse JSON:

```bash
csrf_token=$(curl -c cookie.txt -X POST http://localhost:8080/rest/login \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d 'username=YOUR_USERNAME&password=YOUR_PASSWORD' \
-i | grep 'X-CSRF-Token' | cut -d ' ' -f2)
```

## Making Authenticated API Calls

For all subsequent API calls after login:
- Include the `X-CSRF-Token` in the request headers.
- Ensure that the session cookie received during the login process is included with the request.

### Example using `curl`

```bash
curl -X GET http://localhost:8080/rest/someEndpoint \
-H 'X-CSRF-Token: YOUR_CSRF_TOKEN' \
-b cookie.txt
```
**Note**: Replace `YOUR_USERNAME`, `YOUR_PASSWORD`, and `YOUR_CSRF_TOKEN` with your actual username, password, and CSRF token, respectively. The method of extracting the CSRF token may vary depending on the tools and programming language you are using. The provided examples use common command-line tools.

