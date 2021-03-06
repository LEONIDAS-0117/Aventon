class Request < ApplicationRecord
  belongs_to :user
  belongs_to :viaje
  validate :pending_Score, on:[:create]
  validate :tarjeta
  validate :vencimiento
  before_create :iniciar

  def iniciar
    self.state||=0

  end

  def pending_Score
    if User.current.pending_califications > 0
      errors.add(:base, 'tienes puntuaciones pendientes')
    end
  end

  def tarjeta
    unless User.current.has_credit_card
      errors.add(:base, 'debes registrar tu tarjeta de credito')
    end
  end

  def vencimiento
    if !viaje.es_recurrente
      unless User.current.can_Pay(viaje)
        errors.add(:base, 'tu tarjeta de credito caduca antes del viaje')
      end
    else
      unless User.current.can_Pay(ViajeRecurrente.find(viaje.padreID).lastTravel)
        errors.add(:base, 'tu tarjeta de credito caduca antes del viaje')
      end
    end
  end

  def estado
    if state==0
      m="pendiente"
    else
      if state==1
        m="aceptada"
      else
        if state==2
          m="rechazada"
        else
          m = "cancelada"
        end
      end
    end
  m
  end

  def isPending
    state == 0
    #return true #comentar y descomentar esto para aceptar solicitudes a viajes pasados
  end

  def isAccepted
    state == 1
  end

  def isRefused
    state == 2
  end

  def isCanceled
    state == 3
  end

  def cancel(usuario)

    if !viaje.es_recurrente
      viaje.removePasajero(user) unless self.isPending
      if usuario==self.user
        MyMailer.pasajero_cancela(self).deliver_later(wait: 0.001.second)
        if !self.isPending
          usuario.calificacion_negativa("Pasajero")
        end
      else
        MyMailer.unaFugazza(self).deliver_later(wait: 0.001.second)
        usuario.calificacion_negativa("Chofer")
      end
    else
      ViajeRecurrente.find(viaje.padreID).removePasajero(user) unless self.isPending
      if usuario==self.user
        #MyMailer.pasajero_cancela_rec(self, ViajeRecurrente.find(viaje.padreID)).deliver_later(wait: 0.001.second)
        if !self.isPending
          usuario.calificacion_negativa("Pasajero")
        end
      else
        #MyMailer.chofer_cancela_rec(self, ViajeRecurrente.find(viaje.padreID)).deliver_later(wait: 0.001.second)
        usuario.calificacion_negativa("Chofer")
      end
    end
    self.update_column(:state,3)
  end

  def change(code)
    case code
    when 1
      self.accept
    when 2
      self.refuse
    when 3
      self.cancel(User.current)
    end
  end

  def accept
    if !viaje.es_recurrente
      if viaje.asientos_libres>0 && user.can_Travel(viaje_id)
        if self.update(:state=>1)
          self.viaje.add_Pasajero(self.user)
          MyMailer.announce(self).deliver_later(wait: 0.001.second)
        end
      elsif viaje.asientos_libres == 0
        errors.add(:base,'no puedes aceptar este pasajero porque no hay mas lugar en tu vehiculo')
      else
        errors.add(:base,'no puedes aceptar este pasajero porque tiene otro viaje')
      end
    else
      travelR=ViajeRecurrente.find(viaje.padreID)
      if travelR.next_travel.asientos_libres>0 && user.can_TravelR(travelR.id)
        if self.update(:state=>1)
          travelR.add_Pasajero(self.user)
          #MyMailer.announce(self).deliver_later(wait: 0.001.second)
        end
      elsif travelR.asientos_libres == 0
        errors.add(:base,'no puedes aceptar este pasajero porque no hay mas lugar en tu vehiculo')
      else
        errors.add(:base,'no puedes aceptar este pasajero porque tiene otro viaje')
      end
    end
  end

  def refuse
    self.update_column(:state,2)
  end
end
