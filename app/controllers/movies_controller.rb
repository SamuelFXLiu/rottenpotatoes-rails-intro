class MoviesController < ApplicationController
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.all
    @ratings_to_show = @all_ratings
    
    if (!params.include?(:ratings) && !params.include?(:sort))
      if (session[:curr_sort] != nil && session[:curr_filter] != nil)
        params[:sort] = session[:curr_sort]
        params[:ratings] = session[:curr_filter]
        reset_session
        redirect_to movies_path
      end
    end
    
    if (params.include?(:sort)) 
      if (params[:sort] == "title")
        @cssTitle = "hilite bg-warning"
      elsif (params[:sort] == "release_date")
        @cssHeader = "hilite bg-warning"
      end
      @movies = @movies.sorCol(params[:sort])
    end
        
    if (params.include?(:ratings))
      @ratings_to_show = params[:ratings].keys
      @movies = @movies.with_ratings(@ratings_to_show)
    end
    
    session[:curr_sort] = params[:sort]
    session[:curr_filter] = params[:ratings]
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end


  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
