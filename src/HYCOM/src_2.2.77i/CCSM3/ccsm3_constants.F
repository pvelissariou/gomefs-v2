!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

      module ccsm3_constants
      
      use shr_const_mod

      implicit none
     
      save
      
!-----------------------------------------------------------------------
!
!     parameters
!
!-----------------------------------------------------------------------

      real, parameter :: 
     &  rho_fw = SHR_CONST_RHOFW                !kg/m^3  (freshwater density)
     &, rho_sw = SHR_CONST_RHOSW                !kg/m^3  (seawater density)
     &, cp_sw  = SHR_CONST_CPSW                 !J/kg/K  (specific heat of sea water)
     &, latent_heat_fusion = SHR_CONST_LATICE   !J/kg (3.34e9 erg/g)
     &, cp_over_lhfusion = rho_sw*cp_sw/(latent_heat_fusion*rho_fw)  !1/deg
     
      real, parameter ::
     &  freeze = -1.8                           !deg C (sea water freezing point)
     &, grav   = SHR_CONST_G                    !m/s^2 (gravity)
     &, T0_Kelvin = SHR_CONST_TKFRZ             ! zero point for Celcius
     &, salt_to_ppt   = 1000.                   ! salt (g/g) to ppt
     &, ppt_to_salt   = 1.e-3                   ! salt ppt to g/g
     &, msu2ppt       = salt_to_ppt
     &, ocn_ref_salinity = SHR_CONST_OCN_REF_SAL! psu
     &, ice_ref_salinity = SHR_CONST_ICE_REF_SAL! psu 
     &, cmperm           = 100.0                ! cm per meter
     &, e_radius = SHR_CONST_REARTH*cmperm      ! cm
     
      real, parameter ::
     &  c0p   = 0.0
     &, c1p   = 1.0
     &, c2p   = 2.0
     &, c3p   = 3.0
     &, c4p   = 4.0
     &, c5p   = 5.0
     &, c8p   = 8.0
     &, c10p  = 10.0
     &, c16  = 16.0
     &, c1000= 1000.0
     &, c1p5 = 1.5
     &, p33  = c1p/c3p
     &, pp5  = 0.5
     &, p25  = 0.25
     &, p125 = 0.125
     &, p001 = 0.001
     &, eps  = 1.0e-10
     &, eps2  = 1.0e-20


      end module  ccsm3_constants

!***********************************************************************
