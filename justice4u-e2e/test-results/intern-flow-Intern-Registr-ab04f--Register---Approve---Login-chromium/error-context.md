# Page snapshot

```yaml
- main [ref=e3]:
  - generic [ref=e4]:
    - link " Back to Home" [ref=e5] [cursor=pointer]:
      - /url: Home.html
      - generic [ref=e6]: 
      - text: Back to Home
    - generic [ref=e7]:
      - generic [ref=e8]: 
      - text: Practitioner Portal
    - heading "Precision meets Purpose." [level=1] [ref=e9]:
      - text: Precision
      - text: meets Purpose.
    - paragraph [ref=e10]: Access the firm's central command. Manage case filings, review evidence, and securely communicate with clients from a unified dashboard.
  - generic [ref=e13]:
    - generic [ref=e14]:
      - heading "Partner Login" [level=2] [ref=e15]
      - paragraph [ref=e16]: Authorized personnel only
    - generic [ref=e17]:
      - generic [ref=e18]: Invalid Credentials
      - generic [ref=e19]:
        - generic: 
        - textbox "Lawyer ID" [ref=e20]
      - generic [ref=e21]:
        - generic: 
        - textbox "Encrypted Password" [ref=e22]
      - button "Access Dashboard" [ref=e23] [cursor=pointer]
      - generic [ref=e24]:
        - link "Forgot Password?" [ref=e25] [cursor=pointer]:
          - /url: forgot_password.html?role=lawyer
        - link "Admin" [ref=e26] [cursor=pointer]:
          - /url: Login.html
        - link "Client Access" [ref=e27] [cursor=pointer]:
          - /url: cust_login.html
        - link "Interns" [ref=e28] [cursor=pointer]:
          - /url: internlogin.html
```