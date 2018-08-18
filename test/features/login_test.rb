require "test_helper"

feature "Login" do
  scenario "Login, redirect and display of associated records work" do
    #build a contact person and and two associated record
    contact_persons_email = "CapitalLetterTest@Mail.De"
    contact_person = build(:contact_person, :confirmed, :as_record, hashed_email: "capitallettertest@mail.de")
    contact_person.save(validate: false)
    build(:registration, :as_record, contact_person: contact_person).save(validate: false)
    build(:registration, :as_record, email: "bla@bla.de", contact_person: contact_person).save(validate: false)
    #
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    page.assert_selector('h1', text: 'Login')
    page.assert_no_selector('h1', text: 'Register')
    page.assert_no_selector('td')#no associated records/no tabledata displayed
    #login
    fill_in 'Email', with: contact_persons_email
    click_button 'Submit'
    #check redirect to root_path
    assert_equal root_path, current_path
    page.assert_selector('h1', text: 'Register')
    page.assert_no_selector('h1', text: 'Login')
    #check display of assiociated records
    page.must_have_content("You registered 2 people")
    page.assert_selector('td', text: "1")#record id in tabledata
    page.assert_selector('td', text: "2")
  end
  
  scenario "unconfirmed email doesn't log in" do
    contact_persons_email = build(:contact_person).hashed_email
    build(:contact_person, :as_record).save(validate: false)
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    fill_in 'Email', with: contact_persons_email
    click_button 'Submit'
    #no redirect to registerpage
    assert_equal login_path, current_path
    page.must_have_content("Check your email-account to confirm your email-adress.")
  end
  
  scenario "unknown email doesn't log in" do
    build(:contact_person, :as_record).save(validate: false)
    visit root_path
    #not logged in -> check redirect to login_path
    assert_equal login_path, current_path
    fill_in 'Email', with: "unknown@email.de"
    click_button 'Submit'
    #no redirect to registerpage
    assert_equal login_path, current_path
    page.must_have_content("Check your email-account to confirm your email-adress.")
  end
end