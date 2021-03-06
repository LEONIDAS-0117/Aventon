class CommentsController < ApplicationController

    def indexDelViaje
		@comments = Viaje.find(params[:id]).comment	
	end

	def update
		@comment =Comment.find(params[:id])
		if @comment.update(comment_params)
			redirect_to :action => "indexDelViaje", :id => @comment.viaje.id, :flash => { :notice => "Respuesta guardada" }
		else
		 	redirect_to :action => "indexDelViaje", :id => @comment.viaje.id, :flash => { :notice => @comment.errors.full_messages.join(', ') }
		end 		
	end


    def new
    	@viaje = Viaje.find(params[:idViaje])
		@comment = Comment.new
    end
    def create
    	@usuarios = User.all
		@viaje = Viaje.find(params[:comment][:viaje_id])   	
		@comment = @viaje.comment.new(comment_params)
		current_usuario.comment.new(comment_params)
		if @comment.save
			redirect_to viaje_path(@viaje.id)
		else
			redirect_to :action => "new", :idViaje => @viaje.id, :flash => { :notice => @comment.errors.full_messages.join(', ') }
		end 	
    end
    def comment_params
		params.require(:comment).permit(:pregunta,:respuesta,:respondida)
	end

	def validate_usuario
		redirect_to new_usuario_session_path, notice: "Debes iniciar sesion"
	end	
end