module SearchHelper

def validarRango(rango)
  return if rango.end.blank? || rango.begin.blank?

  if rango.end < rango.begin
    return false
  else
    return true
  end
end

  def formatDate(fecha)
  textYear,textMonth,textDay=fecha[:q].split('-');
  s=Date.new(textYear.to_i,textMonth.to_i,textDay.to_i)
  textYear,textMonth,textDay=fecha[:m].split('-');
  f=Date.new(textYear.to_i,textMonth.to_i,textDay.to_i)
  (s..f)
end
end
