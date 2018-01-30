class StandbyDatesController < ApplicationController
  before_action :set_standby_date, only: [:show, :edit, :update, :destroy]

  # GET /standby_dates
  # GET /standby_dates.json
  def index
    @standby_weeks = StandbyDate.where(driver: current_driver).by_season(selected_season).weeks
    @standby_dates = StandbyDate.where(driver: current_driver).by_season(selected_season).all
  end

  # GET /standby_dates/1
  # GET /standby_dates/1.json
  def show
  end

  # GET /standby_dates/new
  def new
    @standby_date = StandbyDate.new
  end

  # GET /standby_dates/1/edit
  def edit
  end

  # POST /standby_dates
  # POST /standby_dates.json
  def create
    @standby_date = StandbyDate.new({driver_id: current_driver.id}.merge(standby_date_params))

    respond_to do |format|
      if @standby_date.save
        format.html { redirect_to standby_dates_path, notice: 'Standby date was successfully created.' }
        format.json { render :show, status: :created, location: @standby_date }
      else
        format.html { render :new }
        format.json { render json: @standby_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /standby_dates/1
  # PATCH/PUT /standby_dates/1.json
  def update
    respond_to do |format|
      if @standby_date.update(standby_date_params)
        format.html { redirect_to @standby_date, notice: 'Standby date was successfully updated.' }
        format.json { render :show, status: :ok, location: @standby_date }
      else
        format.html { render :edit }
        format.json { render json: @standby_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /standby_dates/1
  # DELETE /standby_dates/1.json
  def destroy
    @standby_date.destroy
    respond_to do |format|
      format.html { redirect_to standby_dates_url, notice: 'Standby date was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_standby_date
      @standby_date = StandbyDate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def standby_date_params
      params.require(:standby_date).permit(:day)
    end
end
