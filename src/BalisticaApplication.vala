/* Copyright 2012-2016 Steven Oliver <oliver.steven@gmail.com>
 *
 * This file is part of balística.
 *
 * balística is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * balística is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with balística.  If not, see <http://www.gnu.org/licenses/>.
 */

// Defined by cmake build script.
extern const string _VERSION_MAJOR ;
extern const string _VERSION_MINOR ;
extern const string _VERSION_REVISION ;
extern const string _VERSION_COMMIT ;
extern const string _VERSION_DESC ;

extern const string _GSETTINGS_DIR ;

namespace Balistica{

   /**
    * These are publicly shared strings that will be
    * available throughout the base of the application
    */
   public const string NAME = "balística" ;
   public const string COPYRIGHT = "Copyright © 2012-2016 Steven Oliver" ;
   public const string WEBSITE = "http://steveno.github.io/balistica/" ;

   public const string DESKTOP_NAME = "balística" ;
   public const string DESKTOP_GENERIC_NAME = "Ballistics Calculator" ;
   public const string DESKTOP_KEYWORDS = "ballistics;calculator;" ;

   public const string VERSION_MAJOR = _VERSION_MAJOR ;
   public const string VERSION_MINOR = _VERSION_MINOR ;
   public const string VERSION_REVISION = _VERSION_REVISION ;
   public const string VERSION_COMMIT = _VERSION_COMMIT ;
   public const string VERSION_DESC = _VERSION_DESC ;

   public const string GSETTINGS_DIR = _GSETTINGS_DIR ;

   public const string[] AUTHORS =
   {
	  "Steven Oliver <oliver.steven@gmail.com>",
	  null
   } ;

   public class Application : Gtk.Application {
	  private GLib.Settings settings ;
	  private Gtk.Window main_window ;
	  private Gtk.Builder drag_builder ;
	  private Gtk.Builder twist_builder ;
	  private Gtk.Builder stability_builder ;

	  // Drag calculation entry fields
	  private Gtk.Entry calc_name ;
	  private Gtk.Entry drag_coefficient ;
	  private Gtk.Entry projectile_weight ;
	  private Gtk.Entry initial_velocity ;
	  private Gtk.Entry zero_range ;
	  private Gtk.Entry sight_height ;
	  private Gtk.Entry shooting_angle ;
	  private Gtk.Entry wind_velocity ;
	  private Gtk.Entry wind_angle ;
	  private Gtk.Entry altitude ;
	  private Gtk.Entry temp ;
	  private Gtk.Entry bar_press ;
	  private Gtk.Entry rela_humid ;

	  // Checkbox for atmospheric corrections
	  private Gtk.CheckButton enable_atmosphere ;

	  // Drag calculation results
	  private Gtk.TextView drag_results ;

	  // Drag calculation Buttons
	  private Gtk.Button reset_drag ;
	  private Gtk.Button solve_drag ;
	  private Gtk.Button pbr ;

	  // Radio buttons for drag functions
	  private Gtk.RadioButton rad_g1 ;
	  private Gtk.RadioButton rad_g2 ;
	  private Gtk.RadioButton rad_g5 ;
	  private Gtk.RadioButton rad_g6 ;
	  private Gtk.RadioButton rad_g7 ;
	  private Gtk.RadioButton rad_g8 ;

	  // Radio buttons for calculation step size
	  private Gtk.RadioButton rad_s10 ;
	  private Gtk.RadioButton rad_s50 ;
	  private Gtk.RadioButton rad_s100 ;

	  // Twist fields
	  private Gtk.Entry miller_diameter ;
	  private Gtk.Entry miller_length ;
	  private Gtk.Entry miller_mass ;
	  private Gtk.Entry miller_safe_value ;
	  private Gtk.Entry greenhill_diameter ;
	  private Gtk.Entry greenhill_length ;
	  private Gtk.Entry greenhill_spec_gravity ;
	  private Gtk.Entry greenhill_c ;
	  private Gtk.Entry twist_results ;

	  // Twist buttons
	  private Gtk.Button reset_twist ;
	  private Gtk.Button solve_twist ;

	  // Radio buttons for calculation step size
	  private Gtk.RadioButton rad_greenhill ;
	  private Gtk.RadioButton rad_miller ;

	  // Stability fields
	  private Gtk.Entry miller_sta_diameter ;
	  private Gtk.Entry miller_sta_length ;
	  private Gtk.Entry miller_sta_mass ;
	  private Gtk.Entry miller_sta_safe_value ;
	  private Gtk.Entry stability_results ;

	  // Stability buttons
	  private Gtk.Button reset_stability ;
	  private Gtk.Button solve_stability ;

	  /**
	   * Constructor
	   */
	  public Application () {
		 GLib.Object (application_id: "org.gnome.balistica") ;
	  }

	  /**
	   * Override the default GTK startup procedure
	   */
	  protected override void startup() {
		 base.startup () ;

		 settings = new GLib.Settings ("org.gnome.balistica") ;

		 main_window = new Gtk.Window () ;
		 Environment.set_application_name (NAME) ;

		 // Setup the main window
		 main_window.title = "balística" ;
		 main_window.window_position = Gtk.WindowPosition.CENTER ;
		 main_window.set_default_size (850, 880) ;
		 main_window.destroy.connect (Gtk.main_quit) ;

		 // Add the main layout grid
		 Gtk.Grid grid = new Gtk.Grid () ;

		 // Add the menu bar across the top
		 Gtk.MenuBar menubar = new Gtk.MenuBar () ;

		 Gtk.MenuItem item_file = new Gtk.MenuItem.with_label ("File") ;
		 Gtk.Menu filemenu = new Gtk.Menu () ;
		 Gtk.MenuItem sub_item_demo = new Gtk.MenuItem.with_label ("Populate Demo") ;
		 filemenu.add (sub_item_demo) ;
		 Gtk.MenuItem sub_item_quit = new Gtk.MenuItem.with_label ("Quit") ;
		 filemenu.add (sub_item_quit) ;
		 item_file.set_submenu (filemenu) ;

		 sub_item_demo.activate.connect (() => {
			populate_demo_selected () ;
		 }) ;

		 sub_item_quit.activate.connect (() => {
			quit_selected () ;
		 }) ;

		 Gtk.MenuItem item_help = new Gtk.MenuItem.with_label ("Help") ;
		 Gtk.Menu helpmenu = new Gtk.Menu () ;
		 Gtk.MenuItem sub_item_about = new Gtk.MenuItem.with_label ("About") ;
		 Gtk.MenuItem sub_item_help = new Gtk.MenuItem.with_label ("Help") ;

		 helpmenu.add (sub_item_about) ;
		 helpmenu.add (sub_item_help) ;
		 item_help.set_submenu (helpmenu) ;

		 sub_item_help.activate.connect (() => {
			help_selected () ;
		 }) ;

		 sub_item_about.activate.connect (() => {
			about_selected () ;
		 }) ;

		 menubar.add (item_file) ;
		 menubar.add (item_help) ;

		 grid.attach (menubar, 0, 0, 1, 1) ;

		 // Add the notebook that will eventually hold everything else
		 Gtk.Notebook notebook = new Gtk.Notebook () ;

		 // Create the drag page of the notebook
		 drag_builder = Balistica.create_builder ("drag.glade") ;
		 drag_builder.connect_signals (null) ;
		 var drag_content = drag_builder.get_object ("drag_main") as Gtk.Box ;
		 notebook.append_page (drag_content, new Gtk.Label ("Drag")) ;

		 // Create the twist page of the notebook
		 twist_builder = Balistica.create_builder ("twist.glade") ;
		 twist_builder.connect_signals (null) ;
		 var twist_content = twist_builder.get_object ("twist_main") as Gtk.Box ;
		 notebook.append_page (twist_content, new Gtk.Label ("Twist")) ;

		 // Create the stability page of the notebook
		 stability_builder = Balistica.create_builder ("stability.glade") ;
		 stability_builder.connect_signals (null) ;
		 var stability_content = stability_builder.get_object ("stability_main") as Gtk.Box ;
		 notebook.append_page (stability_content, new Gtk.Label ("Stability")) ;

		 // Attach the grid (with the notebook) the main window and roll
		 grid.attach (notebook, 0, 1, 1, 1) ;
		 main_window.add (grid) ;
		 main_window.show_all () ;
		 this.add_window (main_window) ;
		 connect_entries () ;
	  }

	  /**
	   * Present the existing main window, or create a new one.
	   */
	  protected override void activate() {
		 base.activate () ;

		 main_window.present () ;
	  }

	  /**
	   * Connect the GUI elements to our code
	   */
	  public void connect_entries() {
		 // Stored drag calculation's name
		 calc_name = drag_builder.get_object ("txtName") as Gtk.Entry ;

		 // Basic drag inputs
		 drag_coefficient = drag_builder.get_object ("txtDrag_coefficient") as Gtk.Entry ;
		 projectile_weight = drag_builder.get_object ("txtProjectile_weight") as Gtk.Entry ;
		 initial_velocity = drag_builder.get_object ("txtIntial_velocity") as Gtk.Entry ;
		 zero_range = drag_builder.get_object ("txtZero_range") as Gtk.Entry ;
		 sight_height = drag_builder.get_object ("txtSight_height") as Gtk.Entry ;
		 shooting_angle = drag_builder.get_object ("txtShooting_angle") as Gtk.Entry ;
		 wind_velocity = drag_builder.get_object ("txtWind_velocity") as Gtk.Entry ;
		 wind_angle = drag_builder.get_object ("txtWind_angle") as Gtk.Entry ;

		 // Setup our example drag calculation
		 setExampleCalculation () ;

		 // Checkbox to dis/en/able atmospheric corrections
		 enable_atmosphere = drag_builder.get_object ("ckbAtmosCorr") as Gtk.CheckButton ;
		 enable_atmosphere.toggled.connect (() => {
			if( enable_atmosphere.active ){
			   // checked
			   altitude.set_sensitive (true) ;
			   temp.set_sensitive (true) ;
			   bar_press.set_sensitive (true) ;
			   rela_humid.set_sensitive (true) ;
			} else {
			   // not checked
			   altitude.set_sensitive (false) ;
			   temp.set_sensitive (false) ;
			   bar_press.set_sensitive (false) ;
			   rela_humid.set_sensitive (false) ;
			}
		 }) ;

		 // Atmospheric corrections
		 altitude = drag_builder.get_object ("txtAltitude") as Gtk.Entry ;
		 temp = drag_builder.get_object ("txtTemp") as Gtk.Entry ;
		 bar_press = drag_builder.get_object ("txtBarPress") as Gtk.Entry ;
		 rela_humid = drag_builder.get_object ("txtRelaHumid") as Gtk.Entry ;

		 // Set default values
		 setDefaultAtmosphere () ;

		 // Drag Calculations Results
		 drag_results = drag_builder.get_object ("txtViewDragResults") as Gtk.TextView ;

		 // Radio buttons for drag functions
		 rad_g1 = drag_builder.get_object ("radG1") as Gtk.RadioButton ;
		 rad_g2 = drag_builder.get_object ("radG2") as Gtk.RadioButton ;
		 rad_g5 = drag_builder.get_object ("radG5") as Gtk.RadioButton ;
		 rad_g6 = drag_builder.get_object ("radG6") as Gtk.RadioButton ;
		 rad_g7 = drag_builder.get_object ("radG7") as Gtk.RadioButton ;
		 rad_g8 = drag_builder.get_object ("radG8") as Gtk.RadioButton ;

		 // Set G1 as selected by default
		 rad_g1.active = true ;

		 // Radio buttons for calculation step size
		 rad_s10 = drag_builder.get_object ("radS10") as Gtk.RadioButton ;
		 rad_s50 = drag_builder.get_object ("radS50") as Gtk.RadioButton ;
		 rad_s100 = drag_builder.get_object ("radS100") as Gtk.RadioButton ;

		 // Set G1 as selected by default
		 rad_s10.active = true ;

		 // Buttons
		 solve_drag = drag_builder.get_object ("btnSolveDrag") as Gtk.Button ;
		 solve_drag.clicked.connect (() => {
			btnSolveDrag_clicked () ;
		 }) ;

		 reset_drag = drag_builder.get_object ("btnResetDrag") as Gtk.Button ;
		 reset_drag.clicked.connect (() => {
			btnResetDrag_clicked () ;
		 }) ;

		 pbr = drag_builder.get_object ("btnPBR") as Gtk.Button ;
		 pbr.clicked.connect (() => {
			btnPBR_clicked () ;
		 }) ;
		 pbr.set_sensitive (false) ;

		 // Setup twist entries & results
		 miller_diameter = twist_builder.get_object ("txtMDiameter") as Gtk.Entry ;
		 miller_length = twist_builder.get_object ("txtMLength") as Gtk.Entry ;
		 miller_mass = twist_builder.get_object ("txtMass") as Gtk.Entry ;
		 miller_safe_value = twist_builder.get_object ("txtSafeValue") as Gtk.Entry ;

		 greenhill_diameter = twist_builder.get_object ("txtGDiameter") as Gtk.Entry ;
		 greenhill_length = twist_builder.get_object ("txtGLength") as Gtk.Entry ;
		 greenhill_spec_gravity = twist_builder.get_object ("txtSpecificGravity") as Gtk.Entry ;
		 greenhill_c = twist_builder.get_object ("txtC") as Gtk.Entry ;

		 twist_results = twist_builder.get_object ("txtResult") as Gtk.Entry ;

		 // Twist buttons
		 reset_twist = twist_builder.get_object ("btnReset") as Gtk.Button ;
		 reset_twist.clicked.connect (() => {
			btnResetTwist_clicked () ;
		 }) ;

		 solve_twist = twist_builder.get_object ("btnCalculate") as Gtk.Button ;
		 solve_twist.clicked.connect (() => {
			btnSolveTwist_clicked () ;
		 }) ;

		 // Radio buttons for twist calculation type
		 rad_miller = twist_builder.get_object ("radMiller") as Gtk.RadioButton ;
		 rad_greenhill = twist_builder.get_object ("radGreenhill") as Gtk.RadioButton ;

		 rad_miller.toggled.connect (() => {
			miller_diameter.set_sensitive (true) ;
			miller_length.set_sensitive (true) ;
			miller_mass.set_sensitive (true) ;
			miller_safe_value.set_sensitive (true) ;

			greenhill_diameter.set_sensitive (false) ;
			greenhill_length.set_sensitive (false) ;
			greenhill_spec_gravity.set_sensitive (false) ;
			greenhill_c.set_sensitive (false) ;
		 }) ;

		 rad_greenhill.toggled.connect (() => {
			miller_diameter.set_sensitive (false) ;
			miller_length.set_sensitive (false) ;
			miller_mass.set_sensitive (false) ;
			miller_safe_value.set_sensitive (false) ;

			greenhill_diameter.set_sensitive (true) ;
			greenhill_length.set_sensitive (true) ;
			greenhill_spec_gravity.set_sensitive (true) ;
			greenhill_c.set_sensitive (true) ;
		 }) ;

		 // Default Twist calculation type
		 rad_miller.active = true ;

		 // Stability fields
		 miller_sta_diameter = stability_builder.get_object ("txtMDiameter") as Gtk.Entry ;
		 miller_sta_length = stability_builder.get_object ("txtMLength") as Gtk.Entry ;
		 miller_sta_mass = stability_builder.get_object ("txtMass") as Gtk.Entry ;
		 miller_sta_safe_value = stability_builder.get_object ("txtSafeValue") as Gtk.Entry ;

		 stability_results = stability_builder.get_object ("txtResult") as Gtk.Entry ;

		 // Stability buttons
		 reset_stability = stability_builder.get_object ("btnReset") as Gtk.Button ;
		 reset_stability.clicked.connect (() => {
			btnResetStability_clicked () ;
		 }) ;

		 solve_stability = stability_builder.get_object ("btnCalculate") as Gtk.Button ;
		 solve_stability.clicked.connect (() => {
			btnSolveStability_clicked () ;
		 }) ;
	  }

	  /**
	   * Reset the front end to prepare for a new drag calculation
	   */
	  public void btnResetDrag_clicked() {
		 calc_name.set_text ("") ;

		 drag_coefficient.set_text ("") ;
		 projectile_weight.set_text ("") ;
		 initial_velocity.set_text ("") ;
		 zero_range.set_text ("") ;
		 sight_height.set_text ("") ;
		 shooting_angle.set_text ("") ;
		 wind_velocity.set_text ("") ;
		 wind_angle.set_text ("") ;

		 setDefaultAtmosphere () ;

		 enable_atmosphere.set_active (false) ;
		 drag_results.buffer.text = "" ;
		 rad_g1.active = true ;
		 rad_s10.active = true ;

		 pbr.set_sensitive (false) ;
	  }

	  /**
	   * Set atmosphere settings back to the default
	   */
	  private void setDefaultAtmosphere() {
		 altitude.set_text ("0") ;
		 temp.set_text ("59.0") ;
		 bar_press.set_text ("29.53") ;
		 rela_humid.set_text ("78.0") ;
	  }

	  /**
	   * Setup an example calculation
	   */
	  private void setExampleCalculation() {
		 btnResetDrag_clicked () ;

		 calc_name.set_text ("308 Win Match, 168gr Sierra Match King") ;
		 drag_coefficient.set_text ("0.465") ;
		 projectile_weight.set_text ("168") ;
		 initial_velocity.set_text ("2650") ;
		 zero_range.set_text ("200") ;
		 sight_height.set_text ("1.6") ;
		 shooting_angle.set_text ("0") ;
		 wind_velocity.set_text ("0") ;
		 wind_angle.set_text ("0") ;
	  }

	  private LibBalistica.DragFunction getDragFunction() {
		 // Which version of the drag do they want to calculate?
		 if( rad_g1.get_active ()){
			return LibBalistica.DragFunction.G1 ;
		 } else if( rad_g2.get_active ()){
			return LibBalistica.DragFunction.G2 ;
		 } else if( rad_g5.get_active ()){
			return LibBalistica.DragFunction.G5 ;
		 } else if( rad_g6.get_active ()){
			return LibBalistica.DragFunction.G6 ;
		 } else if( rad_g7.get_active ()){
			return LibBalistica.DragFunction.G7 ;
		 } else {
			return LibBalistica.DragFunction.G8 ;
		 }
	  }

	  /**
	   * Solve the drag function
	   */
	  public void btnSolveDrag_clicked() {
		 // Name used to store the calculation
		 string name = "" ;
		 // Ballistic cofficient
		 double bc = -1 ;
		 // Initial velocity (ft/s)
		 double v = -1 ;
		 // Sight height over bore (inches)
		 double sh = -1 ;
		 // Projectile weight (grains)
		 double w = -1 ;
		 // Shooting Angle (degrees)
		 double angle = -1 ;
		 // Zero range of the rifle (yards)(
		 double zero = -1 ;
		 // Wind speed (mph)
		 double windspeed = -1 ;
		 // Wind angle (0=headwind, 90=right-to-left, 180=tailwind, 270/-90=left-to-right)
		 double windangle = -1 ;

		 // Altitude
		 double alt = 0.0 ;
		 // Barometeric pressure
		 double bar = 29.53 ;
		 // Temerature
		 double tp = 59.0 ;
		 // Relative Humidity
		 double rh = 78.0 ;

		 name = calc_name.get_text () ;
		 bc = double.parse (drag_coefficient.get_text ()) ;
		 v = double.parse (initial_velocity.get_text ()) ;
		 sh = double.parse (sight_height.get_text ()) ;
		 w = double.parse (projectile_weight.get_text ()) ;
		 angle = double.parse (shooting_angle.get_text ()) ;
		 zero = double.parse (zero_range.get_text ()) ;
		 windspeed = double.parse (wind_velocity.get_text ()) ;
		 windangle = double.parse (wind_angle.get_text ()) ;

		 debug ("Calculation Name = %s", name) ;
		 debug ("Ballistic Coefficent: %f", bc) ;
		 debug ("Intial Velocity: %f", v) ;
		 debug ("Sight Height: %f", sh) ;
		 debug ("Projectile Weight: %f", w) ;
		 debug ("Angle: %f", angle) ;
		 debug ("Zero: %f", zero) ;
		 debug ("Wind speed: %f", windspeed) ;
		 debug ("Wind Angle: %f", windangle) ;

		 // It doesn't make sense for any of the following variables
		 // to be zero
		 if((bc == 0) || (v == 0) || (sh == 0) || (w == 0) || (zero == 0)){
			var drag_builder = new StringBuilder () ;
			drag_builder.append ("The following fields must be positive values greater than 0!\n") ;
			drag_builder.append ("\n\tDrag Coefficient") ;
			drag_builder.append ("\n\tProjectile Weight") ;
			drag_builder.append ("\n\tInitial Velocity") ;
			drag_builder.append ("\n\tZero Range") ;
			drag_builder.append ("\n\tSight Height Over Bore\n") ;

			Gtk.Dialog dialog = new Gtk.Dialog.with_buttons ("Error", null,
															 Gtk.DialogFlags.DESTROY_WITH_PARENT, "OK", Gtk.ResponseType.CLOSE, null) ;
			dialog.response.connect (() => { dialog.destroy () ; }) ;
			dialog.get_content_area ().add (new Gtk.Label (drag_builder.str)) ;
			dialog.set_transient_for (main_window) ;
			dialog.show_all () ;
			dialog.run () ;

			return ;
		 }

		 if( enable_atmosphere.active ){
			alt = double.parse (altitude.get_text ()) ;
			bar = double.parse (bar_press.get_text ()) ;
			tp = double.parse (temp.get_text ()) ;
			rh = double.parse (rela_humid.get_text ()) ;

			debug ("Altitude: %f", alt) ;
			debug ("Barometric Pressure: %f", bar) ;
			debug ("Temperature: %f", tp) ;
			debug ("Relative Humidty: %f", rh) ;
		 }

		 // Create a new solution object
		 LibBalistica.Solution lsln = new LibBalistica.Solution () ;

		 // Calculate the solution and populate the object
		 lsln = Calculate.drag (bc, v, sh, w, angle, zero, windspeed, windangle, alt, bar, tp, rh, name, getDragFunction ()) ;

		 if( lsln.getSolutionSize () == -1 ){
			drag_results.buffer.text = "ERROR creating solution results!" ;
		 } else {
			drag_results.buffer.text = ("") ;
		 }

		 drag_results.buffer.text += ("Drag Coefficient: %.3f  Projectile Weight: %.2f grains\n").printf (lsln.getBc (), lsln.getWeight ()) ;
		 drag_results.buffer.text += ("Initial Velocity: %.2f ft/s  Zero Range: %.2f yards  Shooting Angle: %.2f degrees\n").printf (lsln.getMv (), lsln.getZerorange (), lsln.getAngle ()) ;
		 drag_results.buffer.text += ("Wind Velocity: %.2f mph  Wind Direction: %.2f degrees\n").printf (lsln.getWindspeed (), lsln.getWindangle ()) ;
		 drag_results.buffer.text += ("Altitude: %.2f ft  Barometer: %.2f in-Hg  Temperature: %.2f F  Relative Humidity: %.2f%\n\n").printf (lsln.getAltitude (), lsln.getPressure (), lsln.getTemp (), lsln.getHumidity ()) ;

		 drag_results.buffer.text += "Range\tDropI\tDropM\tVelocity  Energy  Drift\tWindage\tTime\n" ;

		 double r, d, m, wi, wm, t, e ;
		 int max = lsln.getSolutionSize () ;
		 if( max > 1000 ){
			max = 1000 ;
		 }

		 // The user can pick how many steps of the calculation they want to see
		 int step = 1 ;
		 if( rad_s10.get_active ()){
			step = 10 ;
		 } else if( rad_s50.get_active ()){
			step = 50 ;
		 } else if( rad_s100.get_active ()){
			step = 100 ;
		 }

		 for( int n = 0 ; n <= max ; n = n + step ){
			r = lsln.getRange (n) ;
			d = lsln.getDrop (n) ;
			m = lsln.getMOA (n) ;
			v = lsln.getVelocity (n) ;
			wi = lsln.getWindage (n) ;
			wm = lsln.getWindageMOA (n) ;
			t = lsln.getTime (n) ;
			e = lsln.getWeight () * v * v / 450436 ;

			drag_results.buffer.text += ("%.0f\t%.2f\t%.2f\t%.0f      %.0f    %.2f\t%.2f\t%.2f\n").printf (r, d, m, v, e, wi, wm, t) ;
		 }

		 pbr.set_sensitive (true) ;
	  }

	  /**
	   * Open up the new window to calculate the point blank range (PBR)
	   */
	  public void btnPBR_clicked() {
		 Gtk.Window pbr_win = new Balistica.PBRWindow (getDragFunction ()) ;

		 pbr_win.show_all () ;
	  }

	  /**
	   * Reset the front end to prepare for a new twist calculation
	   */
	  public void btnResetTwist_clicked() {
		 miller_diameter.set_text ("") ;
		 miller_length.set_text ("") ;
		 miller_mass.set_text ("") ;
		 miller_safe_value.set_text ("") ;

		 greenhill_diameter.set_text ("") ;
		 greenhill_length.set_text ("") ;
		 greenhill_spec_gravity.set_text ("") ;
		 greenhill_c.set_text ("") ;

		 twist_results.set_text ("") ;
	  }

	  /**
	   * Solve the twist calculation for the selected formula
	   */
	  public void btnSolveTwist_clicked() {
		 if( rad_miller.get_active ()){
			LibBalistica.Miller m = new LibBalistica.Miller () ;

			m.diameter = double.parse (miller_diameter.get_text ()) ;
			m.length = double.parse (miller_length.get_text ()) ;
			m.mass = double.parse (miller_mass.get_text ()) ;
			m.safe_value = int.parse (miller_safe_value.get_text ()) ;

			twist_results.set_text (m.calc_twist ().to_string ()) ;
		 } else {
			LibBalistica.Greenhill g = new LibBalistica.Greenhill () ;

			g.diameter = double.parse (greenhill_diameter.get_text ()) ;
			g.length = double.parse (greenhill_length.get_text ()) ;
			g.specific_gravity = double.parse (greenhill_spec_gravity.get_text ()) ;
			g.C = int.parse (greenhill_c.get_text ()) ;

			twist_results.set_text (g.calc_twist ().to_string ()) ;
		 }
	  }

	  /**
	   * Reset the front end to prepare for a new stability calculation
	   */
	  public void btnResetStability_clicked() {
		 miller_sta_diameter.set_text ("") ;
		 miller_sta_length.set_text ("") ;
		 miller_sta_mass.set_text ("") ;
		 miller_sta_safe_value.set_text ("") ;

		 stability_results.set_text ("") ;
	  }

	  /**
	   * Solve the stability calculation
	   */
	  public void btnSolveStability_clicked() {
		 LibBalistica.Miller m = new LibBalistica.Miller () ;

		 m.diameter = double.parse (miller_sta_diameter.get_text ()) ;
		 m.length = double.parse (miller_sta_length.get_text ()) ;
		 m.mass = double.parse (miller_sta_mass.get_text ()) ;
		 m.safe_value = int.parse (miller_sta_safe_value.get_text ()) ;

		 stability_results.set_text (m.calc_stability ().to_string ()) ;
	  }

/**
 * Populate the drag field with the demostration values
 */
	  private void populate_demo_selected() {
		 setExampleCalculation () ;
	  }

/**
 * Quit application
 */
	  private void quit_selected() {
		 main_window.destroy () ;
	  }

/**
 * Show help browser
 */
	  private void help_selected() {
		 try {
			Gtk.show_uri (main_window.get_screen (), "ghelp:balistica", Gtk.get_current_event_time ()) ;
		 } catch ( Error err ){
			Gtk.Dialog dialog = new Gtk.Dialog.with_buttons ("Error", null,
															 Gtk.DialogFlags.DESTROY_WITH_PARENT, "ERROR: ", Gtk.ResponseType.CLOSE, null) ;
			dialog.response.connect (() => { dialog.destroy () ; }) ;
			dialog.get_content_area ().add (new Gtk.Label ("Error showing help: %s".printf (err.message))) ;
			dialog.show_all () ;
			dialog.run () ;
		 }
	  }

/**
 * Show about dialog
 */
	  private void about_selected() {
		 string version ;

		 if( Balistica.VERSION_DESC == "Release" ){
			version = Balistica.VERSION_MAJOR + "." + Balistica.VERSION_MINOR + "." + Balistica.VERSION_REVISION ;
		 } else {
			version = Balistica.VERSION_MAJOR + "." + Balistica.VERSION_MINOR + "." + Balistica.VERSION_REVISION + "-" + Balistica.VERSION_COMMIT ;
		 }

		 Gtk.show_about_dialog (main_window,
								"authors", Balistica.AUTHORS,
								"comments", "An open source external ballistics calculator.",
								"copyright", Balistica.COPYRIGHT,
								"license-type", Gtk.License.GPL_3_0,
								"program-name", Balistica.NAME,
								"website", Balistica.WEBSITE,
								"website-label", "balística Website",
								"version", version) ;
	  }

   }
} // namespace
