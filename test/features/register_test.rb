require "test_helper"

feature "Register" do
  
  def setup
    #logged in
    contact_persons_email = build(:contact_person).hashed_email
    build(:contact_person, :confirmed, :as_record).save(validate: false)
    visit login_path
    fill_in 'Email', with: contact_persons_email
    click_button 'Submit'
  end
  
  scenario "Register works" do
    registration = build(:registration)
    page.must_have_content("You registered 0 people")
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    fill_in 'Cellphone Number', with: registration.phonenumber
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    page.must_have_content "You registered #{registration.name} for the festival"
    page.must_have_content("You registered 1 person")
  end
  
  scenario "Registration missing phonenumber is invalid" do
    registration = build(:registration)
    page.must_have_content("You registered 0 people")
    fill_in 'Name', with: registration.name
    fill_in 'Email', with: registration.email
    select_date_and_time '21,June,15', :from => 'Arrival'
    select_date_and_time '27,June,15', :from => 'Departure'
    click_button 'Submit'
    page.must_have_content "Cellphone Number can't be blank"
    page.must_have_content("You registered 0 people")
  end
end
