/*
 * Copyright (c) 2008 Stanford University.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Stanford University nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL STANFORD
 * UNIVERSITY OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Kevin Klues <klueska@cs.stanford.edu>
 */

#include <Msp430Adc12.h>
generic configuration BlockingAdcReadStreamClientC() {
  provides interface BlockingReadStream<uint16_t>;
  uses interface AdcConfigure<const msp430adc12_channel_config_t*>;
} implementation {
  components BlockingAdcP,
#ifdef REF_VOLT_AUTO_CONFIGURE     
             // if the client configuration requires a stable 
             // reference voltage, the reference voltage generator 
             // is automatically enabled
             new Msp430Adc12ClientAutoRVGC() as Msp430AdcPlient;
#else
             new Msp430Adc12ClientC() as Msp430AdcPlient;
#endif

  enum {
    RSCLIENT = unique(ADCC_READ_STREAM_SERVICE),
  };

  BlockingReadStream = BlockingAdcP.BlockingReadStream[RSCLIENT];
  AdcConfigure = BlockingAdcP.ConfigReadStream[RSCLIENT];
  BlockingAdcP.SingleChannelReadStream[RSCLIENT] -> Msp430AdcPlient.Msp430Adc12SingleChannel;
  BlockingAdcP.ResourceReadStream[RSCLIENT] -> Msp430AdcPlient.Resource;
#ifdef REF_VOLT_AUTO_CONFIGURE
  AdcConfigure = Msp430AdcPlient.AdcConfigure;
#endif
}
  
