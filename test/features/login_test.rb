require "test_helper"

feature "Login" do
  scenario "Login, redirect and display of associated records" do
    #create a contact person record and and associated registrations records
    contact_person = create_confirmed_contact_person("capitallettertest@mail.de")
    registrations_count = 3
#     build(:registration, :encrypted, contact_person: contact_person).save(validate: false)
#     build(:registration, :encrypted, email: "bla@bla.de", contact_person: contact_person).save(validate: false)
    registrations_count.times do build(:registration, :sequence, :encrypted, contact_person: contact_person).save(validate: false) end
    #
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    page.assert_selector('h1', text: 'Login')
    page.assert_no_selector('h1', text: 'Register')
    page.assert_no_selector('td')#no associated records/no tabledata displayed
    #login
    fill_in 'Email', with: "CapitalLetterTest@Mail.De"
    click_button 'Submit'
    #check redirect to root_path
    assert_equal root_path, current_path
    page.assert_selector('h1', text: 'Register')
    page.assert_no_selector('h1', text: 'Login')
    #check display of assiociated records
    page.must_have_content("You registered #{registrations_count} people")
    page.assert_selector('td', text: "1")
    page.assert_selector('td', text: "#{registrations_count}")#record id in tabledata
  end
  
  scenario "unconfirmed email doesn't log in" do
    contact_persons_email = build(:contact_person).hashed_email
    build(:contact_person, :email_hashed).save(validate: false)
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    fill_in 'Email', with: contact_persons_email
    click_button 'Submit'
    #no redirect to registerpage
    assert_equal login_path, current_path
    page.must_have_content("Check your email-account to confirm your email-address.")
  end
  
  scenario "login with unknown email doesn't log in" do
    build(:contact_person, :email_hashed, :confirmed).save(validate: false)
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    fill_in 'Email', with: "unknown@email.de"
    click_button 'Submit'
    #no redirect to registerpage
    assert_equal login_path, current_path
    page.must_have_content("Check your email-account to confirm your email-address.")
  end
  
end