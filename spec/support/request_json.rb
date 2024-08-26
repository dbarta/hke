module RequestJson
  def login_json
    {email: "admin@hakhel.com",
     password: "password"}
  end

  def register_json
    {
      user: {
        name: "admin",
        email: "admin@hakhel.com",
        terms_of_service: "1",
        password: "password"
      }
    }
  end

  def address_json
    {
      address_type: "billing",
      line1: "28 Hanna st.",
      city: "Haifa",
      country: "Israel",
      postal_code: "23415"
    }
  end

  # Helper to construct JSON for a contact person
  def contact_person_json(include_address: true, destroy: false)
    contact_data = {
      first_name: "שוש",
      last_name: "זולו",
      gender: "female",
      phone: "034556275"
    }
    contact_data[:address_attributes] = address_json if include_address
    contact_data[:_destroy] = "1" if destroy
    contact_data
  end

  # Helper to construct JSON for a relation
  def relation_json(include_contact: true, include_contact_address: false, destroy: false)
    relation_data = {
      relation_of_deceased_to_contact: "בת"
    }
    relation_data[:contact_person_attributes] = contact_person_json(include_address: include_contact_address) if include_contact
    relation_data[:_destroy] = "1" if destroy
    relation_data
  end

  # Helper to construct JSON for creating a deceased person
  def deceased_person_json(include_relation: false, include_contact_address: false)
    dp_data = {
      deceased_person:
        {
          first_name: "אחאב",
          last_name: "אלמוג",
          gender: "male",
          hebrew_year_of_death: "תשכ״ד",
          hebrew_month_of_death: "אייר",
          hebrew_day_of_death: "ג"
          # date_of_death: "1964-04-15",
          # relations_attributes: [relation_json]
        }
    }
    dp_data[:deceased_person][:relations_attributes] = [relation_json(include_contact: true, include_contact_address: include_contact_address)] if include_relation
    dp_data
  end

  def deceased_person_json1(include_relation: false, include_contact_address: false)
    dp_data = {
      deceased_person:
        {
          first_name: "שרה",
          last_name: "חרובי",
          gender: "female",
          hebrew_year_of_death: "תשכ״ד",
          hebrew_month_of_death: "תשרי",
          hebrew_day_of_death: "י"
          # date_of_death: "1964-04-15",
          # relations_attributes: [relation_json]
        }
    }
    dp_data[:deceased_person][:relations_attributes] = [relation_json(include_contact: true, include_contact_address: include_contact_address)] if include_relation
    dp_data
  end

  def deceased_person_json2(include_relation: false, include_contact_address: false)
    dp_data = {
      deceased_person:
        {
          first_name: "יוסף",
          last_name: "כרוביון",
          gender: "male",
          hebrew_year_of_death: "תשל״ד",
          hebrew_month_of_death: "כסלו",
          hebrew_day_of_death: "י״ד"
          # date_of_death: "1964-04-15",
          # relations_attributes: [relation_json]
        }
    }
    dp_data[:deceased_person][:relations_attributes] = [relation_json(include_contact: true, include_contact_address: include_contact_address)] if include_relation
    dp_data
  end
end
