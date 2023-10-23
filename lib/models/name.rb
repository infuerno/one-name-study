# type is :birth_name, :married_name, :also_known_as, :nickname, :adoptive_name, :formal_name, :religious_name
# name_forms is [] of NameForm
class Name < Conclusion
  attr_reader :type, :name_forms, :date
  def initialize(type, name_forms, date=nil)
    @type = type,
    @name_forms = name_forms,
    @date = date
  end
end

# full_text is string
# parts is [] of NamePart
class NameForm
  attr_reader :full_text, :parts
  def initialize(full_text, parts=[])
    @full_text = full_text,
    @parts = parts
  end
end

# type is one of :prefix, :suffix, :given, :surname
# value is string
class NamePart
  attr_reader :type, :value
  def initialize(type, value)
    @type = type
    @value = value
  end
end



