/* Copyright 2012 Steven Oliver <oliver.steven@gmail.com> 
 *
 * This file is part of balistica.
 *
 * balistica is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * balistica is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with balistica.  If not, see <http://www.gnu.org/licenses/>.
 */

/* The code in this file was originally part of the GNU Exterior 
 * Balisitics Computer. It was licensed under the GNU General Public
 * License Version 2 by Derek Yates.
 * 
 * I obviously converted it from C to Vala.
 */

using GLib;
using Conversion;

public class Balistica.LibBalistica.Windage : GLib.Object {

        /** 
         * A function to compute the windage deflection for a given crosswind speed,
         * given flight time in a vacuum, and given flight time in real life.
         *
         * @param WindSpeed The wind velocity in mi/hr.
         * @param Vi The initial velocity of the projectile (muzzle velocity).
         * @param x The range at which you wish to determine windage, in feet.
         * @param t The time it has taken the projectile to traverse the range x, in seconds.
         *
         * @return The amount of windage correction, in inches, required to achieve zero on a target at the given range.	
         */
        public double CalcWindage(double WindSpeed, double Vi, double xx, double t){
                double Vw = WindSpeed * 17.60; // Convert to inches per second.

                return (Vw * (t - xx / Vi));
        }

        /**
         * Headwind is positive at WindAngle = 0
         * @param WindSpeed
         * @param WindAngle
         *
         * @return HeadWind
         */
        public double HeadWind(double WindSpeed, double WindAngle){
                double Wangle = Angle.DegreeToRadian(WindAngle);

                return (Math.cos(Wangle) * WindSpeed);
        }

        /**
         * Positive is from Shooter's Right to Left (Wind from 90 degree)
         *
         * @param WindSpeed The wind velocity, in mi/hr.
         * @param WindAngle The angle from which the wind is coming, in degrees.
         *                      0 degrees is from straight ahead
         *                      90 degrees is from right to left
         *                      180 degrees is from directly behind
         *                      270 or -90 degrees is from left to right
         *
         * @return The headwind or crosswind velocity component, in mi/hr.
         */
        public double CrossWind(double WindSpeed, double WindAngle){
                double Wangle = Angle.DegreeToRadian(WindAngle);

                return (Math.sin(Wangle) * WindSpeed);
        }
}

