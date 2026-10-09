import pytest
import time
from playwright.sync_api import sync_playwright
from page_objects import RegistrationPage

@pytest.fixture(scope="function")
def page():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        yield page
        browser.close()

def test_successful_registration(page):
    # TC-01: Positive / Smoke
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    unique_email = f"test_user_{int(time.time())}@example.com"
    reg_page.fill_form("Ivan", "Ivanov", unique_email, "ValidPass123!")
    reg_page.submit()
    page.wait_for_url("**/contactList", timeout=5000)
    assert "contactList" in page.url

def test_empty_email(page):
    # TC-02: Negative
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    reg_page.fill_form("Ivan", "Ivanov", "", "ValidPass123!")
    reg_page.submit()
    assert "Email is invalid" in reg_page.get_error()

def test_invalid_email_format(page):
    # TC-03: Negative
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    reg_page.fill_form("Ivan", "Ivanov", "ivanovexample.com", "ValidPass123!")
    reg_page.submit()
    assert "Email is invalid" in reg_page.get_error()

def test_password_too_short(page):
    # TC-04: Negative / Boundary (min-1)
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    reg_page.fill_form("Ivan", "Ivanov", f"test_{int(time.time())}@ex.com", "123456")
    reg_page.submit()
    # Contact List app requires min 7 chars for password
    assert "Path `password`" in reg_page.get_error() and "shorter than the minimum allowed length" in reg_page.get_error()

def test_empty_first_name(page):
    # TC-05: Negative
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    reg_page.fill_form("", "Ivanov", "valid@example.com", "ValidPass123!")
    reg_page.submit()
    assert "Path `firstName` is required" in reg_page.get_error()

def test_existing_email(page):
    # TC-06: Negative (existing user)
    # Сначала создаем юзера
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    unique_email = f"test_exist_{int(time.time())}@example.com"
    reg_page.fill_form("Ivan", "Ivanov", unique_email, "ValidPass123!")
    reg_page.submit()
    page.wait_for_url("**/contactList")
    
    # Теперь пытаемся зарегистрироваться с тем же email
    page.context.clear_cookies() # очищаем сессию
    reg_page.navigate()
    reg_page.fill_form("Petr", "Petrov", unique_email, "ValidPass123!")
    reg_page.submit()
    assert "Email address is already in use" in reg_page.get_error()

def test_sql_injection_email(page):
    # TC-07: Security
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    reg_page.fill_form("Admin", "Adminov", "admin' OR 1=1--", "ValidPass123!")
    reg_page.submit()
    assert "Email is invalid" in reg_page.get_error()

def test_password_exact_boundary(page):
    # TC-08: Boundary (min)
    reg_page = RegistrationPage(page)
    reg_page.navigate()
    unique_email = f"test_bound_{int(time.time())}@example.com"
    # min password length is 7
    reg_page.fill_form("Ivan", "Ivanov", unique_email, "1234567")
    reg_page.submit()
    page.wait_for_url("**/contactList", timeout=5000)
    assert "contactList" in page.url
