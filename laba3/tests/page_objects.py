class RegistrationPage:
    def __init__(self, page):
        self.page = page
        self.url = "https://thinking-tester-contact-list.herokuapp.com/addUser"
        
        # Селекторы
        self.first_name_input = page.locator("#firstName")
        self.last_name_input = page.locator("#lastName")
        self.email_input = page.locator("#email")
        self.password_input = page.locator("#password")
        self.submit_btn = page.locator("#submit")
        self.error_msg = page.locator("#error")

    def navigate(self):
        self.page.goto(self.url)

    def fill_form(self, first_name, last_name, email, password):
        self.first_name_input.fill(first_name)
        self.last_name_input.fill(last_name)
        self.email_input.fill(email)
        self.password_input.fill(password)

    def submit(self):
        self.submit_btn.click()

    def get_error(self):
        self.page.wait_for_selector("#error", timeout=5000)
        return self.error_msg.inner_text()
