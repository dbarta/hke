# try the hebcal API for translating / convrting Hebrew dates to/from Greorian dates

# require 'csv'
require 'httparty'
require 'json'
module Hke
    # Returns the hebrew letter number, or zero if not a hebrew letter
    def self.hebrew_letter_to_number(aleph)
        i = "אבגדהוזחטיכלמנסעפצקרשת".index(aleph) # The string should be read from right to left
        if i == nil then
            # Maybe ot sofit
            i = "אבגדהוזחטיךלםןסעףץקרשת".index(aleph)
        end
        i == nil ? 0 : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400][i]
    end

    def self.clean_name(text)
        # Remove non hebrew characters, do leave space
        letters =  "ךלםןסעףץאבגדהוזחטיכלמנסעפצקרשת "
        text1 = ""
        text.split('').each do |a|
            next if letters.index(a) == nil
            text1 += a
        end

        text1
    end

    def self.hebrew_month_to_english(hebrew_month)
        h = self.clean_name(hebrew_month)
        mt={'ניסן' => :Nisan, 'אייר' => :Iyyar, 'סיון' => :Sivan, 'סיוון' => :Sivan, 'תמוז' => :Tamuz,
            'אב' => :Av, 'אלול' => :Elul, 'תשרי' => :Tishrei, 'חשון' => :Cheshvan,
            'חשוון' => :Cheshvan,
            'כיסלו' => :Kislev, 'כסלו' => :Kislev, 'טבת' => :Tevet, 'שבט' => :Shvat, 'אדר' => :Adar,
            'אדר א' => :Adar1,
            'אדר ב' => :Adar2 }
        mt[h]
    end

    def self.english_month_to_hebrew(english_month)
        mt = {
            Tishrei: 'תשרי',
            Cheshvan: 'חשוון',
            Kislev: 'כסלו',
            Tevet: 'טבת',
            Shvat: 'שבט',
            Adar: 'אדר',
            Adar1: 'אדר א׳',
            Adar2: 'אדר ב׳',
            Nisan: 'ניסן',
            Iyyar: 'אייר',
            Sivan: 'סיוון',
            Tamuz: 'תמוז',
            Av: 'אב',
            Elul: 'אלול'
        }
        mt[english_month]
    end

    def self.hebrew_date_numeric_value day
        day.split('').map{|a| hebrew_letter_to_number(a)}.sum
    end

    def self.prepare_hebrew_date_for_hebcal(year, month, day)
        m = self.hebrew_month_to_english(month)
        d = self.hebrew_date_numeric_value(day)
        y = year.split('').map{|a| self.hebrew_letter_to_number(a)}.sum
        y = y + 5000 - 5 if year[0] == "ה"
        [y, m, d]
    end

    def self.h2g(name, y, m, d)
        if !y || !m || !d
            puts "ERROR: an element is missing from the Hebrew date for #{name}."
            return nil
        end

        v = self.prepare_hebrew_date_for_hebcal(y, m, d)

        #puts "y: #{y.reverse};#{v[0]}  hm=|#{m.reverse}|;#{v[1]}  hd=|#{d.reverse}|;#{v[2]}"

        uri="https://www.hebcal.com/converter?cfg=json&hy=#{v[0]}&hm=#{v[1].to_s}&hd=#{v[2]}&h2g=1"
        response = HTTParty.get(uri)
        #puts response.body, response.code #, response.message, response.headers.inspect
        # {"gy":2005,"gm":10,"gd":20,"afterSunset":false,"hy":5766,"hm":"Tishrei","hd":17,
        # "hebrew":"י״ז בְּתִשְׁרֵי תשס״ו","events":["Sukkot III (CH''M)"]}

        d1 = JSON.parse(response.body)
        begin
            Date.new(d1['gy'],d1['gm'],d1['gd'],)
        rescue
            puts "Error in Date for #{d1}"
            puts "y: #{y.reverse};#{v[0]}  hm=|#{m.reverse}|;#{v[1]}  hd=|#{d.reverse}|;#{v[2]}"
        end
    end

    # csv_text = File.read('נפטרים עם קרובים 1.csv')
    # csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
    # csv[0..5].each do |row|
    #   puts h2g(row['שנת פטירה'], row['חודש פטירה'], row['יום פטירה'])
    # end
end