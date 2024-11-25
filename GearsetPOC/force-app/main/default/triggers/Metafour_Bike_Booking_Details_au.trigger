trigger Metafour_Bike_Booking_Details_au on Metafour_Bike_Booking_Details__c (after insert, after update) {
    /***
	*Triger to Update Log andLog detail object when a booking created successfully in metafour and corresponding consignment number is returned.
	*/
        for(Metafour_Bike_Booking_Details__c bk : Trigger.new){
            
            String[] strDate = bk.Train_Date__c.split('-');
            Integer myIntDate = integer.valueOf(strDate[0]);
        	Integer myIntMonth = integer.valueOf(strDate[1]);
        	Integer myIntYear = integer.valueOf(strDate[2]);

        	Date dt = Date.newInstance(myIntYear,myIntMonth,myIntDate);
            
            Metafour_Bike_Availability_Logs__c bikeAvailLogs2 ;
			system.debug('in trigger before Bike loop ::'+bk.Bike_or_Luggage__c);

			if(bk.Bike_or_Luggage__c ==  'Bike'){
                
           system.debug('in trigger in Bike loop ::'+bk);

				/*Fetching the corresponding Log table entry of the case related list for updation*/
            Metafour_Bike_Availability_Logs__c bikeAvailLogs = [Select id,Train_Id__c,Train_Number__c,Date__c,From_Station__c,To_Station__c,Available_Assembled_Space__c,Total_Assembled_Tickets__c,Booked_Assembled_Tickets__c,Unconfirmed_Assembled_Tickets__c,Available_Boxed_Space__c,Total_Boxed_Tickets__c,Booked_Boxed_Tickets__c,Unconfirmed_Boxed_Tickets__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bk.Train_Number__c and Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :bk.To_Station__c and Bike_or_Luggage__c = 'Bike' limit 1];
                                    
                system.debug('in trigger bikeAvailLogs::'+bikeAvailLogs);
        
            if(bikeAvailLogs != null){

                if(bk.Booking_Status__c == 'Success' && bk.Consignment_Number__c != null){
                    
                    system.debug('in trigger bikeAvailLogs:: '+bikeAvailLogs);
                     
                    /*Update the unconfired spaces to booked status*/
                    if(bk.Luggage_Type__c == 'Boxed' && bk.No_Of_Pieces__c > 0){
                        
                        bikeAvailLogs.Unconfirmed_Boxed_Tickets__c = bikeAvailLogs.Unconfirmed_Boxed_Tickets__c - bk.No_Of_Pieces__c;
                        bikeAvailLogs.Booked_Boxed_Tickets__c = bikeAvailLogs.Booked_Boxed_Tickets__c + bk.No_Of_Pieces__c;
                        

                    
                    }else if(bk.Luggage_Type__c == 'Assembled' && bk.No_Of_Pieces__c > 0){
                        
                        bikeAvailLogs.Unconfirmed_Assembled_Tickets__c = bikeAvailLogs.Unconfirmed_Assembled_Tickets__c - bk.No_Of_Pieces__c;
                        bikeAvailLogs.Booked_Assembled_Tickets__c = bikeAvailLogs.Booked_Assembled_Tickets__c+ bk.No_Of_Pieces__c;

                    }
					
					/*Update the log record*/
                    update bikeAvailLogs;
					

					/*Fetching the corresponding Log detail table entry of the case related list for updation*/
					Metafour_Bike_Availability_Log_Details__c logDetail  = [select id,Booking_Status__c,Luggauge_Type__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c = :bk.Train_Number__c and Train_Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :bk.To_Station__c and Luggauge_Type__c = :bk.Luggage_Type__c and Number_of_Spaces__c = :bk.No_Of_Pieces__c and Booking_Status__c = 'Unconfirmed' and Bike_or_Luggage__c = 'Bike' limit 1];
                    system.debug('in trigger logDetail::'+logDetail);
                    
                    if(logDetail != null){
                        logDetail.Booking_Status__c = 'Booked';
                    }
					/*Update the logDetail record*/

					update logDetail;  
				
				
				
				
                    /*Checking if the to station is an intermediate station*/
                    if(bk.Is_Intermediate_Station__c == true){
                        
						/*Fetching the full jouney train detail corresponding to this entry*/
                        Metafour_Bike_Capacity__c trainCapacity  = [Select From_Station__c,To_Station__c,Train_Number__c,Intermediate_stop__c  from Metafour_Bike_Capacity__c where From_Station__c = :bk.From_Station__c and Train_Number__c =:bk.Train_Number__c and  Intermediate_stop__c = false  limit 1];
						/*Fetching the full jouney train detail from Log table*/
                        bikeAvailLogs2 = [Select Train_Id__c,Train_Number__c,Date__c,From_Station__c,To_Station__c,Available_Assembled_Space__c,Total_Assembled_Tickets__c,Booked_Assembled_Tickets__c,Unconfirmed_Assembled_Tickets__c,Available_Boxed_Space__c,Total_Boxed_Tickets__c,Booked_Boxed_Tickets__c,Unconfirmed_Boxed_Tickets__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bk.Train_Number__c and Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :trainCapacity.To_Station__c and Bike_or_Luggage__c = 'Bike' limit 1];
                        
                     	system.debug('in trigger bikeAvailLogs2::'+bikeAvailLogs2);
                        
                        

                        if(bk.Luggage_Type__c == 'Boxed' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Boxed_Tickets__c = bikeAvailLogs2.Unconfirmed_Boxed_Tickets__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Boxed_Tickets__c = bikeAvailLogs2.Booked_Boxed_Tickets__c + bk.No_Of_Pieces__c;

                    
                    	}else if(bk.Luggage_Type__c == 'Assembled' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Assembled_Tickets__c = bikeAvailLogs2.Unconfirmed_Assembled_Tickets__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Assembled_Tickets__c = bikeAvailLogs2.Booked_Assembled_Tickets__c+ bk.No_Of_Pieces__c;

                    	}
                        /*updating the full jouney train details*/
                        update bikeAvailLogs2;
						
                        
						Metafour_Bike_Availability_Log_Details__c logDetail2  = [select id,Booking_Status__c,Luggauge_Type__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c = :bk.Train_Number__c and Train_Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :trainCapacity.To_Station__c and Luggauge_Type__c = :bk.Luggage_Type__c and Number_of_Spaces__c = :bk.No_Of_Pieces__c and Booking_Status__c = 'Unconfirmed' and Bike_or_Luggage__c = 'Bike' limit  1];
						
                     	system.debug('in trigger logDetail2::'+logDetail2);

						if(logDetail2 != null){
							logDetail2.Booking_Status__c = 'Booked';
						}
                        /*Update the logDetail record*/
						update logDetail2;  
                    }
  
                    
                }
                

                
            }
			}
			
			//For Luggage booking
			
			if(bk.Bike_or_Luggage__c ==  'Luggage'){
				/*Fetching the corresponding Log table entry of the case related list for updation*/
            Metafour_Bike_Availability_Logs__c bikeAvailLogs = [Select id,Train_Id__c,Train_Number__c,Date__c,From_Station__c,To_Station__c,Total_Available_Luggage_space__c,Available_Space_EL_Over85__c,Available_Space_EL_Under85__c,Available_Space_Group_Booking__c,Available_Space_VIP_Booking__c,Booked_Space_EL_Over85__c,Booked_Space_EL_Under85__c,Booked_Space_Group_Booking__c,Booked_Space_VIP_Booking__c,           Total_Space_EL_Over85__c,Total_Space_EL_Under85__c,Total_Space_Group_Booking__c,Total_Space_VIP_Booking__c,Unconfirmed_Space_EL_Over85__c,Unconfirmed_Space_EL_Under85__c,Unconfirmed_Space_Group_Booking__c,Unconfirmed_Space_VIP_Booking__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bk.Train_Number__c and Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :bk.To_Station__c and Bike_or_Luggage__c = 'Luggage' limit 1];
                        
            if(bikeAvailLogs != null){

                if(bk.Booking_Status__c == 'Success' && bk.Consignment_Number__c != null){
                    
                    system.debug('in trigger bikeAvailLogs:: '+bikeAvailLogs);
                     
                    /*Update the unconfired spaces to booked status*/
                   
				   if(bk.Luggage_Type__c == 'Excess Luggage Over 85' && bk.No_Of_Pieces__c > 0){
                
						bikeAvailLogs.Unconfirmed_Space_EL_Over85__c = bikeAvailLogs.Unconfirmed_Space_EL_Over85__c - bk.No_Of_Pieces__c;
						bikeAvailLogs.Booked_Space_EL_Over85__c = bikeAvailLogs.Booked_Space_EL_Over85__c+ bk.No_Of_Pieces__c;
                
					}else if(bk.Luggage_Type__c == 'Excess Luggage Under 85' && bk.No_Of_Pieces__c > 0){
                
						bikeAvailLogs.Unconfirmed_Space_EL_Under85__c = bikeAvailLogs.Unconfirmed_Space_EL_Under85__c - bk.No_Of_Pieces__c;
						bikeAvailLogs.Booked_Space_EL_Under85__c = bikeAvailLogs.Booked_Space_EL_Under85__c+ bk.No_Of_Pieces__c;

                
					}else if(bk.Luggage_Type__c == 'Group Luggage' && bk.No_Of_Pieces__c > 0){
                
						bikeAvailLogs.Unconfirmed_Space_Group_Booking__c = bikeAvailLogs.Unconfirmed_Space_Group_Booking__c - bk.No_Of_Pieces__c;
						bikeAvailLogs.Booked_Space_Group_Booking__c = bikeAvailLogs.Booked_Space_Group_Booking__c+ bk.No_Of_Pieces__c;
                
					}else if(bk.Luggage_Type__c == 'VIP Services' && bk.No_Of_Pieces__c > 0){
                
						bikeAvailLogs.Unconfirmed_Space_VIP_Booking__c = bikeAvailLogs.Unconfirmed_Space_VIP_Booking__c - bk.No_Of_Pieces__c;
						bikeAvailLogs.Booked_Space_VIP_Booking__c = bikeAvailLogs.Booked_Space_VIP_Booking__c+ bk.No_Of_Pieces__c;

					}
					
					/*Update the log record*/
                    update bikeAvailLogs;
					
			
            
			
					
					
					/*Fetching the corresponding Log detail table entry of the case related list for updation*/
					Metafour_Bike_Availability_Log_Details__c logDetail  = [select id,Booking_Status__c,Luggauge_Type__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c = :bk.Train_Number__c and Train_Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :bk.To_Station__c and Luggauge_Type__c = :bk.Luggage_Type__c and Number_of_Spaces__c = :bk.No_Of_Pieces__c and Booking_Status__c = 'Unconfirmed' and Bike_or_Luggage__c = 'Luggage' limit 1];
					
                    system.debug('in trigger logDetail::'+logDetail);
                    
                    if(logDetail != null){
                        logDetail.Booking_Status__c = 'Booked';
                    }
					/*Update the logDetail record*/

					update logDetail;  
				
				
				
				
                    //Checking if the to station is an intermediate station*/
                   /* if(bk.Is_Intermediate_Station__c == true){
                        
						//Fetching the full jouney train detail corresponding to this entry//
                        Metafour_Bike_Capacity__c trainCapacity  = [Select From_Station__c,To_Station__c,Train_Number__c,Intermediate_stop__c  from Metafour_Bike_Capacity__c where From_Station__c = :bk.From_Station__c and Train_Number__c =:bk.Train_Number__c and  Intermediate_stop__c = false  limit 1];
						//Fetching the full jouney train detail from Log table//
                        bikeAvailLogs2 = [Select Train_Id__c,Train_Number__c,Date__c,From_Station__c,To_Station__c,Available_Assembled_Space__c,Total_Assembled_Tickets__c,Booked_Assembled_Tickets__c,Unconfirmed_Assembled_Tickets__c,Available_Boxed_Space__c,Total_Boxed_Tickets__c,Booked_Boxed_Tickets__c,Unconfirmed_Boxed_Tickets__c from Metafour_Bike_Availability_Logs__c where Train_Number__c = :bk.Train_Number__c and Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :trainCapacity.To_Station__c and Bike_or_Luggage__c = 'Luggage' limit 1];
                        
                     	system.debug('in trigger bikeAvailLogs2::'+bikeAvailLogs2);
                        
                        

                         if(bk.Luggage_Type__c == 'Excess Luggage Over 85' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Space_EL_Over85__c = bikeAvailLogs2.Unconfirmed_Space_EL_Over85__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Space_EL_Over85__c = bikeAvailLogs2.Booked_Space_EL_Over85__c+ bk.No_Of_Pieces__c;

                    	}else if(bk.Luggage_Type__c == 'Excess Luggage Under 85' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Space_EL_Under85__c = bikeAvailLogs2.Unconfirmed_Space_EL_Under85__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Space_EL_Under85__c = bikeAvailLogs2.Booked_Space_EL_Under85__c+ bk.No_Of_Pieces__c;

                    	}else if(bk.Luggage_Type__c == 'Group Luggage' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Space_Group_Booking__c = bikeAvailLogs2.Unconfirmed_Space_Group_Booking__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Space_Group_Booking__c = bikeAvailLogs2.Booked_Space_Group_Booking__c+ bk.No_Of_Pieces__c;

                    	}else if(bk.Luggage_Type__c == 'VIP Services' && bk.No_Of_Pieces__c > 0){
                        
                        	bikeAvailLogs2.Unconfirmed_Space_VIP_Booking__c = bikeAvailLogs2.Unconfirmed_Space_VIP_Booking__c - bk.No_Of_Pieces__c;
                        	bikeAvailLogs2.Booked_Space_VIP_Booking__c = bikeAvailLogs2.Booked_Space_VIP_Booking__c+ bk.No_Of_Pieces__c;

                    	}
						
						 
						
                        //updating the full jouney train details//
                        update bikeAvailLogs2;
						
                        
						Metafour_Bike_Availability_Log_Details__c logDetail2  = [select id,Booking_Status__c,Luggauge_Type__c from Metafour_Bike_Availability_Log_Details__c where Train_Number__c = :bk.Train_Number__c and Train_Date__c = :dt and From_Station__c = :bk.From_Station__c and To_Station__c = :trainCapacity.To_Station__c and Luggauge_Type__c = :bk.Luggage_Type__c and Number_of_Spaces__c = :bk.No_Of_Pieces__c and Booking_Status__c = 'Unconfirmed' and Bike_or_Luggage__c = 'Luggage' limit 1];
						
                     	system.debug('in trigger logDetail2::'+logDetail2);

						if(logDetail2 != null){
							logDetail2.Booking_Status__c = 'Booked';
						}
                        //Update the logDetail record//
						update logDetail2;  
                    }
  */
                    
                }
                

                
            }
			}
            
        }

}