class ScenariosController < ApplicationController
  before_action :set_scenario, only: [:show, :edit, :update, :destroy]

  # GET /scenarios
  # GET /scenarios.json
  def index
    @scenarios = Scenario.all
  end

  # GET /scenarios/1
  # GET /scenarios/1.json
  def show
    @cloud_booted = @scenario.clouds.select { |cloud| cloud.booted? }.size
    @cloud_count = @scenario.clouds.size
    @subnet_booted = @scenario.clouds.map { |cloud| cloud.subnets }.flatten.select { |subnet| subnet.booted? }.size
    @subnet_count = @scenario.clouds.map { |cloud| cloud.subnets }.flatten.size
    @instance_booted = @scenario.clouds.map { |cloud| cloud.subnets }.flatten.map { |subnet| subnet.instances }.flatten.select { |instance| instance.booted? }.size
    @instance_count = @scenario.clouds.map { |cloud| cloud.subnets }.flatten.map { |subnet| subnet.instances }.flatten.size
  end
  
  def boot
    @scenario = Scenario.find(params[:id])
    if @scenario.booted?
      notice = "Scenario is booted. Monitor output below."
    elsif @scenario.booting?
      notice = "Scenario is booting. Monitor output below."
    else
      @scenario.delay.boot
      notice = "Scenario is booting. Monitor output below."
    end

    redirect_to @scenario, notice: notice
  end

  def dev_boot
    @scenario = Scenario.find(params[:id])
    if @scenario.booted?
      notice = "Scenario is booted. Monitor output below."
    elsif @scenario.booting?
      notice = "Scenario is booting. Monitor output below."
    else
      @scenario.boot
      notice = "Scenario is booting. Monitor output below."
    end

    redirect_to @scenario, notice: notice
  end

  # GET /scenarios/new
  def new
    @scenario = Scenario.new
    @templates = YmlRecord.yml_headers.map {|filename,name,desc| [name,filename]}
  end

  # GET /scenarios/1/edit
  def edit
    @templates = []
  end

  # POST /scenarios
  # POST /scenarios.json
  def create
    if template = scenario_params["template"]
      @scenario = YmlRecord.load_yml("scenarios-yml/#{template}")
    else
      @scenario = Scenario.new(scenario_params)
    end

    respond_to do |format|
      if @scenario.save
        format.html { redirect_to @scenario, notice: 'Scenario was successfully created.' }
        format.json { render :show, status: :created, location: @scenario }
      else
        format.html { render :new }
        format.json { render json: @scenario.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scenarios/1
  # PATCH/PUT /scenarios/1.json
  def update
    respond_to do |format|
      if @scenario.update(scenario_params)
        format.html { redirect_to @scenario, notice: 'Scenario was successfully updated.' }
        format.json { render :show, status: :ok, location: @scenario }
      else
        format.html { render :edit }
        format.json { render json: @scenario.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scenarios/1
  # DELETE /scenarios/1.json
  def destroy
    @scenario.destroy
    respond_to do |format|
      format.html { redirect_to scenarios_url, notice: 'Scenario was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scenario
      @scenario = Scenario.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scenario_params
      params.require(:scenario).permit(:game_type, :name, :template, :log)
    end
end
