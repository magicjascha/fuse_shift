require "test_helper"

feature "Register" do
  
  def setup
    #logged in
    Capybara.current_driver = Capybara.javascript_driver

#     Capybara.current_driver = :selenium
    @contact_persons_email = "maja.the.contact@mail.de"
    contact_person = create_confirmed_contact_person(@contact_persons_email)
    visit login_path
    fill_in 'Email', with: @contact_persons_email
    click_button 'Submit'
  end
  
  scenario "Register" do    
    registration = build(:registration_input)
    page.must_have_content("You registered 0 people")
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    page.execute_script("$('#registration_start').val('#{registration.start}')")
    page.execute_script("$('#registration_end').val('#{registration.end}')")
    click_button 'Submit'
    page.must_have_content "You registered #{registration.name} for the festival"
    page.must_have_content("You registered 1 person")
  end
  
  scenario "Registration without name is invalid" do
    registration = build(:registration_input)
    page.must_have_content("You registered 0 people")
    fill_in 'Email', with: registration.email
    page.execute_script("$('#registration_start').val('#{registration.start}')")
    page.execute_script("$('#registration_end').val('#{registration.end}')")
    click_button 'Submit'
    page.must_have_content "Name can't be blank"
    page.must_have_content("You registered 0 people")
  end
  
  scenario "local storage fills names of associated records" do
    registrations_count = 10#must be bigger 1, session overflow when bigger 5
    names = []
    registrations_count.times do 
      click_link 'New Registration'
      registration = build(:registration_input, :sequence)
      names.push(registration.name)
      find('input#registration_email.form-control', wait: 5)
      fill_in 'Name', with: registration.name
      fill_in 'Email', with: registration.email
      page.execute_script("$('#registration_start').val('#{registration.start}')")
      page.execute_script("$('#registration_end').val('#{registration.end}')")
      click_button 'Submit'
      find('div#editpage_email.form-control-static', wait: 5)
    end
    page.must_have_content("You registered #{registrations_count} people")
    page.assert_selector('td', text: "#{names[0]}")
    page.assert_selector('td', text: "#{names[registrations_count-1]}")#name from factory-sequence in tabledata
#     save_and_open_page
#     save_and_open_screenshot
  end
  
  scenario "localstorage fills in edit-form" do
    #make a registration
    registration = build(:registration)
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    page.execute_script("$('#registration_start').val('#{registration.start}')")
    page.execute_script("$('#registration_end').val('#{registration.end}')")
    click_button 'Submit'
    #
    find('div#editpage_email.form-control-static', wait: 5)
    #wait for the page to load
    #check if we're on the edit page
    assert_equal "/registrations/#{registration.hashed_email}", current_path
    page.assert_selector('h1', text: "Edit registration")
    #check if the edit-form is filled in
    assert_equal find_field('Name').value, registration.name
  end

#not working because js-alert can't be captured
#   scenario "delete browser-memory" do
#     #register
#     registration = build(:registration)
#     fill_in 'Name', with: registration.name
#     fill_in 'Email', with: registration.email
#     page.execute_script("$('#registration_start').val('#{registration.start}')")
#     page.execute_script("$('#registration_end').val('#{registration.end}')")
#     click_button 'Submit'
#     #check session-fill in on edit-page
#     visit "/registrations/#{registration.hashed_email}"
#     assert_equal find_field('Name').value, registration.name
# 
#     #delete localstorage and refresh page
#     page.execute_script 'localStorage.clear()'
# 
# #     page.refresh
# #     byebug
# #     wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoSuchAlertError
# # #     wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
# #     alert = wait.until { page.driver.browser.switch_to.alert }
# #     alert.accept
# #     page.refresh
# 
#     page.refresh
#     
# #     page.driver.findElement(By.xpath("//input[@name='Explanation']")).sendKeys("OK").accept()
# 
# #     page.evaluate_script('window.alert = function() { return true; }')
# #     page.refresh('Remove')
# #     accept_alert do
# # #       click_link 'Delete Browser-Memory'
# #       page.refresh
# #     end
# #     page.refresh
# #     sleep 1.second
# 
#     #check if registration data is deleted
#     visit "/registrations/#{registration.hashed_email}"
#     page.assert_selector('h1', text: "Edit registration with ID")
#     assert_no_text registration.name
#     
#   end

  
end
