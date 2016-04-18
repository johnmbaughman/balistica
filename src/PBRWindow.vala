/* Copyright 2016 Steven Oliver <oliver.steven@gmail.com>
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

namespace Balistica{

   public class PBRWindow : Gtk.Window {
	  private Gtk.Builder pbr_builder ;

	  private Gtk.Button pbr_calc ;
	  private Gtk.Entry drag_coef ;
	  private Gtk.Entry inital_vel ;
	  private Gtk.Entry sight_height ;
	  private Gtk.Entry vital_zone ;

	  private Gtk.TextView results ;

	  public LibBalistica.DragFunction solved_drag;

	  /**
	   * Constructor
	   */ 
	  public PBRWindow(LibBalistica.DragFunction drag) {
		 this.title = "Optimize Point Blank Range" ;
		 this.window_position = Gtk.WindowPosition.CENTER ;

		 pbr_builder = new Gtk.Builder () ;
		 pbr_builder = Balistica.create_builder ("pbr.glade") ;

		 pbr_builder.connect_signals (null) ;
		 var pbr_content = pbr_builder.get_object ("pbr_main") as Gtk.Box ;
		 this.solved_drag = drag;

		 this.add(pbr_content);
		 this.show_all () ;
	  }

	  /**
	   * Connect the GUI elements to our code 
	   */
	  public void connect_entries() {
		 pbr_calc = pbr_builder.get_object ("btnOptimizePBR") as Gtk.Button ;
		 pbr_calc.clicked.connect (() => {
			btnOptimizePBR_clicked () ;
		 }) ;

		 drag_coef = pbr_builder.get_object ("txtDragCoef") as Gtk.Entry ;
		 inital_vel = pbr_builder.get_object ("txtIntialVel") as Gtk.Entry ;
		 sight_height = pbr_builder.get_object ("txtSightHeight") as Gtk.Entry ;
		 vital_zone = pbr_builder.get_object ("txtVitalZone") as Gtk.Entry ;

		 results = pbr_builder.get_object("txtResults") as Gtk.TextView;
	  }

	  /**
	   * Setup an example calculation
	   */
	  private void setExampleCalculation() {
		 drag_coef.set_text ("0.465") ;
		 inital_vel.set_text ("2650") ;
		 sight_height.set_text ("1.6") ;
		 vital_zone.set_text ("3") ;
	  }

	  /**
	   * Optimize the point blank range for the given entries
       */
	  public void btnOptimizePBR_clicked() {
		 double dc = double.parse (drag_coef.get_text ()) ;
		 double iv = double.parse (inital_vel.get_text ()) ;
		 double sh = double.parse (sight_height.get_text ()) ;
		 double vz = double.parse (vital_zone.get_text ()) ;
		 double[] result;

		 LibBalistica.PBR.pbr (this.solved_drag, dc, iv, sh, vz, out result) ;

		 results.buffer.text = "";
		 results.buffer.text += ("Near Zero: %f yards\nFar Zero: %f yards\nMinimum PBR: %f yards\nMaximum PBR: %f yards\nSight-in at 100yds: %.2f High").printf(result[0], result[1], result[2],result[3],result[4]/100.0);
	  }

   }
} // namespace
